import 'dart:io';
import 'package:admin_dvij/categories/place_categories/place_categories_list.dart';
import 'package:admin_dvij/categories/place_categories/place_category.dart';
import 'package:admin_dvij/categories/place_categories/place_category_picker.dart';
import 'package:admin_dvij/cities/cities_list_class.dart';
import 'package:admin_dvij/cities/city_class.dart';
import 'package:admin_dvij/cities/city_picker_page.dart';
import 'package:admin_dvij/constants/places_constants.dart';
import 'package:admin_dvij/places/place_admin/current_place_admins_list_screen.dart';
import 'package:admin_dvij/places/place_class.dart';
import 'package:admin_dvij/places/places_list_class.dart';
import 'package:admin_dvij/system_methods/system_methods_class.dart';
import 'package:admin_dvij/users/admin_user/admin_user_class.dart';
import 'package:admin_dvij/users/simple_users/creator_popup.dart';
import 'package:admin_dvij/users/simple_users/simple_user.dart';
import 'package:admin_dvij/users/simple_users/simple_users_list.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import '../constants/buttons_constants.dart';
import '../constants/city_constants.dart';
import '../constants/system_constants.dart';
import '../constants/users_constants.dart';
import '../database/image_picker.dart';
import '../dates/regular_date_class.dart';
import '../design/app_colors.dart';
import '../design/loading_screen.dart';
import '../design_elements/button_state_enum.dart';
import '../design_elements/elements_of_design.dart';

class PlaceCreateViewEditScreen extends StatefulWidget {

  final Place? place;

  const PlaceCreateViewEditScreen({this.place, Key? key}) : super(key: key);

  @override
  State<PlaceCreateViewEditScreen> createState() => _PlaceCreateViewEditScreenState();
}

class _PlaceCreateViewEditScreenState extends State<PlaceCreateViewEditScreen> {

  AdminUserClass currentAdminUser = AdminUserClass.empty();

  PlacesList placesList = PlacesList();
  SimpleUsersList usersList = SimpleUsersList();
  SystemMethodsClass sm = SystemMethodsClass();
  PlaceCategoriesList placeCategoriesList = PlaceCategoriesList();
  CitiesList citiesList = CitiesList();
  final ImagePickerService imagePickerService = ImagePickerService();

  bool loading = false;
  bool saving = false;
  bool deleting = false;
  bool canEdit = false;
  bool showSchedule = false;

  File? _imageFile;

  Place editPlace = Place.empty();
  SimpleUser creator = SimpleUser.empty();

  PlaceCategory chosenCategory = PlaceCategory.empty();
  City chosenCity = City.empty();
  SimpleUser chosenCreator = SimpleUser.empty();

  RegularDate schedule = RegularDate();


  final TextEditingController nameController = TextEditingController();
  final TextEditingController descController = TextEditingController();
  final TextEditingController creatorController = TextEditingController();
  final TextEditingController createDateController = TextEditingController();
  final TextEditingController categoryController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController streetController = TextEditingController();
  final TextEditingController houseController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController whatsappController = TextEditingController();
  final TextEditingController telegramController = TextEditingController();
  final TextEditingController instagramController = TextEditingController();

  @override
  void initState() {
    initialization();
    super.initState();
  }

  Future<void> initialization({bool fromDb = false}) async {

    // Подгружаем текущего пользователя
    currentAdminUser = await currentAdminUser.getCurrentUser(fromDb: false);

    setState(() {
      loading = true;
    });

    // Подгружаем список заведений и список пользователей
    if (fromDb){
      await placesList.getDownloadedList(fromDb: fromDb);
      await usersList.getDownloadedList(fromDb: fromDb);
    }

    // Если это создание, то устанавливаем режим редактирования и показ расписания сразу
    if (widget.place == null){
      canEdit = true;
      showSchedule = true;
    }

    // Если редактирование, подгружаем создателя и редактируемое заведение. Устанавливаем расписание
    if (widget.place != null){
      editPlace = placesList.getEntityFromList(widget.place!.id);
      creator = usersList.getEntityFromList(editPlace.creatorId);
      setSchedule();
    }

    // Сбрасываем текстовые поля и выбранные настройки по умолчанию
    setTextFieldsOnDefault();

    setState(() {
      loading = false;
    });

  }

  @override
  Widget build(BuildContext context) {

    final isMobile = MediaQuery.of(context).size.width < 600; // Условие для мобильной версии

    return Scaffold(
      appBar: AppBar(
        title: Text(
            widget.place != null && widget.place!.name.isNotEmpty
                ? '${PlacesConstants.watchPlace} "${editPlace.name}"'
                : PlacesConstants.createPlace
        ),

        leading: IconButton(
          icon: const Icon(FontAwesomeIcons.chevronLeft, size: 18,),
          onPressed: () {
            navigateToPlacesListScreen();
          },
        ),

        actions: [

          // Иконка обновления данных.

          if (widget.place != null) IconButton(
            onPressed: () async {
              await initialization(fromDb: true);
            },
            icon: const Icon(FontAwesomeIcons.arrowsRotate, size: 15, color: AppColors.white,),
          ),

          // Иконка редактирования. Доступна если у текущего админа есть доступ или это не создание заведения

          if (currentAdminUser.adminRole.accessToEditPlaces() && widget.place != null) IconButton(
            onPressed: () async {
              setState(() {
                canEdit = true;
              });
            },
            icon: const Icon(FontAwesomeIcons.penToSquare, size: 15, color: AppColors.white,),
          ),

          if (currentAdminUser.adminRole.accessToDeletePlaces() && widget.place != null) IconButton(
            onPressed: () async {
              await deletePlace();
            },
            icon: const Icon(FontAwesomeIcons.trash, size: 15, color: AppColors.white,),
          ),

        ],
      ),

      body: Stack(
        children: [
          if (loading) const LoadingScreen(loadingText: SystemConstants.loadingDefault)
          else if (saving) const LoadingScreen(loadingText: SystemConstants.saving)
          else if (deleting) const LoadingScreen(loadingText: SystemConstants.deleting)
          else SingleChildScrollView(
              child: Center(
                child: Container(
                  width: sm.getScreenWidth(neededWidth: 800),
                  padding: EdgeInsets.all(isMobile ? 20 : 30),
                  margin: EdgeInsets.symmetric(
                      vertical: Platform.isWindows || Platform.isMacOS ? 20 : 10,
                      horizontal: Platform.isWindows || Platform.isMacOS ? 0 : 10
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.greyOnBackground,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [

                      // Todo - заменить все изображения на этот виджет
                      ElementsOfDesign.imageForEditViewScreen(
                          context: context,
                          imageUrl: editPlace.imageUrl,
                          imageFile: _imageFile,
                          canEdit: canEdit,
                          onEditImage: () async {
                            await _pickImage();
                          }
                      ),

                      const SizedBox(height: 20,),

                      ElementsOfDesign.buildTextField(
                          controller: nameController,
                          labelText: PlacesConstants.namePlace,
                          canEdit: canEdit,
                          icon: FontAwesomeIcons.heading,
                          context: context
                      ),

                      const SizedBox(height: 20,),

                      ElementsOfDesign.buildTextField(
                        controller: descController,
                        labelText: PlacesConstants.descPlace,
                        canEdit: canEdit,
                        icon: FontAwesomeIcons.paragraph,
                        context: context,
                        maxLines: null,
                      ),

                      const SizedBox(height: 20,),

                      ElementsOfDesign.buildAdaptiveRow(
                          isMobile: isMobile,
                          children: [
                            ElementsOfDesign.buildTextField(
                                controller: cityController,
                                labelText: UserConstants.city,
                                canEdit: canEdit,
                                icon: FontAwesomeIcons.city,
                                context: context,
                                readOnly: true,
                                onTap: () async {
                                  await chooseCity();
                                }
                            ),
                            ElementsOfDesign.buildTextField(
                                controller: categoryController,
                                labelText: PlacesConstants.categoryPlace,
                                canEdit: canEdit,
                                icon: FontAwesomeIcons.tag,
                                context: context,
                                readOnly: true,
                                onTap: () async {
                                  await chooseCategory();
                                }
                            )
                          ]
                      ),
                      ElementsOfDesign.buildAdaptiveRow(
                          isMobile: isMobile,
                          children: [
                            ElementsOfDesign.buildTextField(
                                controller: streetController,
                                labelText: PlacesConstants.streetPlace,
                                canEdit: canEdit,
                                icon: FontAwesomeIcons.road,
                                context: context
                            ),
                            ElementsOfDesign.buildTextField(
                              controller: houseController,
                              labelText: PlacesConstants.homePlace,
                              canEdit: canEdit,
                              icon: FontAwesomeIcons.building,
                              context: context,
                            )
                          ]
                      ),

                      ElementsOfDesign.buildAdaptiveRow(
                          isMobile: isMobile,
                          children: [
                            ElementsOfDesign.buildTextField(
                                controller: phoneController,
                                labelText: UserConstants.phone,
                                canEdit: canEdit,
                                icon: FontAwesomeIcons.phone,
                                context: context
                            ),
                            ElementsOfDesign.buildTextField(
                              controller: whatsappController,
                              labelText: UserConstants.whatsapp,
                              canEdit: canEdit,
                              icon: FontAwesomeIcons.whatsapp,
                              context: context,
                            )
                          ]
                      ),

                      ElementsOfDesign.buildAdaptiveRow(
                          isMobile: isMobile,
                          children: [
                            ElementsOfDesign.buildTextField(
                                controller: telegramController,
                                labelText: UserConstants.telegram,
                                canEdit: canEdit,
                                icon: FontAwesomeIcons.telegram,
                                context: context
                            ),
                            ElementsOfDesign.buildTextField(
                              controller: instagramController,
                              labelText: UserConstants.instagram,
                              canEdit: canEdit,
                              icon: FontAwesomeIcons.instagram,
                              context: context,
                            )
                          ]
                      ),

                      ElementsOfDesign.buildAdaptiveRow(
                          isMobile: isMobile,
                          children: [
                            ElementsOfDesign.buildTextField(
                                controller: createDateController,
                                labelText: PlacesConstants.createDatePlace,
                                canEdit: false,
                                icon: FontAwesomeIcons.calendar,
                                context: context
                            ),
                            ElementsOfDesign.buildTextField(
                                controller: creatorController,
                                labelText: PlacesConstants.creatorPlace,
                                canEdit: canEdit && currentAdminUser.adminRole.accessToEditCreator(),
                                icon: FontAwesomeIcons.signature,
                                context: context,
                                readOnly: true,
                                onTap: () async {
                                  await chooseCreator();
                                }
                            )
                          ]
                      ),

                      schedule.getRegularEditWidget(
                          context: context,
                          onTapStart: (index) => pickTime(index, true),
                          onTapEnd: (index) => pickTime(index, false),
                          canEdit: canEdit,
                        showSchedule: showSchedule,
                        show: (){
                            setState(() {
                              showSchedule = !showSchedule;
                            });
                        }
                      ),

                      if (widget.place != null) const SizedBox(height: 20,),

                      if (widget.place != null) GestureDetector(
                        onTap: () async {
                          await goToAdminsPage();

                        },
                        child: Row(
                          children: [
                            Expanded(
                                child: Text(
                                  PlacesConstants.adminsPlace,
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                            ),

                            IconButton(
                                onPressed: () async {
                                  await goToAdminsPage();
                                },
                                icon: const Icon(FontAwesomeIcons.chevronRight, size: 15,)
                            )
                          ],
                        ),
                      ),

                      const SizedBox(height: 20,),

                      if (canEdit) ElementsOfDesign.buildAdaptiveRow(
                          isMobile: isMobile,
                          children: [
                            ElementsOfDesign.customButton(
                                method: () async {
                                  await savePlace();

                                },
                                textOnButton: ButtonsConstants.save,
                                context: context
                            ),

                            ElementsOfDesign.customButton(
                                method: (){
                                  setTextFieldsOnDefault();
                                  setState(() {
                                    canEdit = false;
                                  });

                                },
                                textOnButton: ButtonsConstants.cancel,
                                context: context,
                                buttonState: ButtonStateEnum.secondary
                            ),
                          ]
                      ),

                    ],
                  ),
                ),
              ),
            )
        ],
      ),

    );
  }

  Future<void> goToAdminsPage() async {
    final result = await sm.pushToPageWithResult(context: context, page: CurrentPlaceAdminsListScreen(place: editPlace));

    if (result != null) {
      await initialization();
    }
  }

  void setSchedule(){
    schedule.mondayStart = editPlace.openingHours.mondayStart;
    schedule.mondayEnd = editPlace.openingHours.mondayEnd;
    schedule.tuesdayStart = editPlace.openingHours.tuesdayStart;
    schedule.tuesdayEnd = editPlace.openingHours.tuesdayEnd;
    schedule.wednesdayStart = editPlace.openingHours.wednesdayStart;
    schedule.wednesdayEnd = editPlace.openingHours.wednesdayEnd;
    schedule.thursdayStart = editPlace.openingHours.thursdayStart;
    schedule.thursdayEnd = editPlace.openingHours.thursdayEnd;
    schedule.fridayStart = editPlace.openingHours.fridayStart;
    schedule.fridayEnd = editPlace.openingHours.fridayEnd;
    schedule.saturdayStart = editPlace.openingHours.saturdayStart;
    schedule.saturdayEnd = editPlace.openingHours.saturdayEnd;
    schedule.sundayStart = editPlace.openingHours.sundayStart;
    schedule.sundayEnd = editPlace.openingHours.sundayEnd;
  }

  void setTextFieldsOnDefault(){
    setState(() {
      nameController.text = editPlace.name;
      descController.text = editPlace.desc;
      creatorController.text = creator.getFullName().isNotEmpty ? creator.getFullName() : PlacesConstants.chooseCreatorPlace;
      createDateController.text = sm.formatDateTimeToHumanView(editPlace.createDate);
      categoryController.text = editPlace.category.name.isNotEmpty ? editPlace.category.name : PlacesConstants.chooseCategoryPlace;
      cityController.text = editPlace.city.name.isNotEmpty ? editPlace.city.name : CityConstants.cityNotChosen;
      streetController.text = editPlace.street;
      houseController.text = editPlace.house;
      phoneController.text = editPlace.phone;
      whatsappController.text = editPlace.whatsapp;
      telegramController.text = editPlace.telegram;
      instagramController.text = editPlace.instagram;
      setSchedule();

      chosenCreator = SimpleUser.empty();
      chosenCategory = PlaceCategory.empty();
      chosenCity = City.empty();

      _imageFile = null;
    });
  }

  Future<void> deletePlace () async {

    bool? result = await ElementsOfDesign.exitDialog(
      context,
      PlacesConstants.deletePlaceDesc,
      ButtonsConstants.delete,
      ButtonsConstants.cancel,
        PlacesConstants.deletePlaceHeadline
    );

    if (result != null && result){
      setState(() {
        deleting = true;
      });

      String publishResult = await editPlace.deleteFromDb();

      if (publishResult == SystemConstants.successConst){

        _showSnackBar(PlacesConstants.deletePlaceSuccess);
        navigateToPlacesListScreen();

      } else {
        _showSnackBar(publishResult);
      }

      setState(() {
        saving = false;
      });
    }

  }

  Place setPlaceBeforeSaving(){

    Place tempPlace = Place.empty();

    if (chosenCategory.id.isNotEmpty){
      tempPlace.category = chosenCategory;
    } else {
      tempPlace.category = editPlace.category;
    }

    if (chosenCity.id.isNotEmpty){
      tempPlace.city = chosenCity;
    } else {
      tempPlace.city = editPlace.city;
    }

    if (chosenCreator.uid.isNotEmpty){
      tempPlace.creatorId = chosenCreator.uid;
    } else {
      tempPlace.creatorId = editPlace.creatorId;
    }

    tempPlace.createDate = editPlace.createDate;
    tempPlace.street = streetController.text;
    tempPlace.house = houseController.text;
    tempPlace.phone = phoneController.text;
    tempPlace.whatsapp = whatsappController.text;
    tempPlace.instagram = instagramController.text;
    tempPlace.telegram = telegramController.text;
    tempPlace.name = nameController.text;
    tempPlace.desc = descController.text;
    tempPlace.openingHours = schedule;
    tempPlace.imageUrl = editPlace.imageUrl;
    tempPlace.id = editPlace.id;

    return tempPlace;

  }

  /// Обновляем время
  void updateTime(int index, bool isStart, TimeOfDay newTime) {
    setState(() {
      switch (index) {
        case 0:
          isStart ? schedule.mondayStart = newTime : schedule.mondayEnd = newTime;
          break;
        case 1:
          isStart ? schedule.tuesdayStart = newTime : schedule.tuesdayEnd = newTime;
          break;
        case 2:
          isStart ? schedule.wednesdayStart = newTime : schedule.wednesdayEnd = newTime;
          break;
        case 3:
          isStart ? schedule.thursdayStart = newTime : schedule.thursdayEnd = newTime;
          break;
        case 4:
          isStart ? schedule.fridayStart = newTime : schedule.fridayEnd = newTime;
          break;
        case 5:
          isStart ? schedule.saturdayStart = newTime : schedule.saturdayEnd = newTime;
          break;
        case 6:
          isStart ? schedule.sundayStart = newTime : schedule.sundayEnd = newTime;
          break;
      }
    });
  }

  /// Показ диалога выбора времени
  Future<void> pickTime(int index, bool isStart) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: schedule.getTime(index: index, isStart: true) ?? TimeOfDay.now(),
      initialEntryMode: TimePickerEntryMode.inputOnly,
    );
    if (picked != null) {
      updateTime(index, isStart, picked);
    }
  }

  void _showSnackBar(String message){
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  String checkPlace(Place tempPlace){

    if (tempPlace.name.isEmpty){
      return PlacesConstants.noNameError;
    }
    if (tempPlace.desc.isEmpty){
      return PlacesConstants.noDescError;
    }
    if (tempPlace.creatorId.isEmpty){
      return PlacesConstants.noCreatorError;
    }

    if (tempPlace.city.id.isEmpty){
      return PlacesConstants.noCityError;
    }
    if (tempPlace.category.id.isEmpty){
      return PlacesConstants.noCategoryError;
    }
    if (tempPlace.street.isEmpty){
      return PlacesConstants.noStreetError;
    }

    if (tempPlace.house.isEmpty){
      return PlacesConstants.noHomeError;
    }

    if (tempPlace.phone.isEmpty){
      return PlacesConstants.noPhoneError;
    }

    if (!schedule.checkRegularDate()){
      return PlacesConstants.noScheduleError;
    }

    return SystemConstants.successConst;

  }

  Future<void> savePlace() async{
    setState(() {
      saving = true;
    });

    Place tempPlace = setPlaceBeforeSaving();


    if (checkPlace(tempPlace) == SystemConstants.successConst){

      String publishResult = await tempPlace.publishToDb(_imageFile);

      if (publishResult == SystemConstants.successConst) {

        if (chosenCreator.uid.isNotEmpty){
          creator.deletePlaceRoleFromUser(editPlace.id);
        }

        await initialization();



        _showSnackBar(PlacesConstants.savePlaceSuccess);

        canEdit = false;
        setTextFieldsOnDefault();
        //resetChosenOptions();

        if (widget.place == null){
          navigateToPlacesListScreen();
        }

      } else {
        _showSnackBar(publishResult);
      }
    } else {
      _showSnackBar(checkPlace(tempPlace));
    }

    setState(() {
      saving = false;
    });
  }

  void navigateToPlacesListScreen() {
    sm.popBackToPreviousPageWithResult(context: context, result: editPlace);
  }

  Future<void> _pickImage() async {

    // TODO - сделать подборщика картинок на macOs

    final File? pickedImage = await imagePickerService.pickImage(ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        _imageFile = pickedImage;
      });
    }
  }

  Future<void> chooseCreator() async{
    final results = await sm.getPopup(context: context, page: CreatorPopup(placeId: editPlace.id,));
    if (results != null){
      chosenCreator = results;
      creatorController.text = chosenCreator.getFullName();
    }
  }

  Future<void> chooseCity() async{
    final results = await sm.getPopup(context: context, page: const CityPickerPage());
    if (results != null){
      chosenCity = results;
      cityController.text = chosenCity.name;
    }
  }

  Future<void> chooseCategory() async{
    final results = await sm.getPopup(context: context, page: const PlaceCategoryPicker());
    if (results != null){
      chosenCategory = results;
      categoryController.text = chosenCategory.name;
    }
  }

}
