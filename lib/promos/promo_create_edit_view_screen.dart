import 'dart:io';
import 'package:admin_dvij/address/address_or_place_class.dart';
import 'package:admin_dvij/address/address_type_picker.dart';
import 'package:admin_dvij/categories/promo_categories/promo_category.dart';
import 'package:admin_dvij/constants/city_constants.dart';
import 'package:admin_dvij/constants/errors_constants.dart';
import 'package:admin_dvij/constants/events_constants.dart';
import 'package:admin_dvij/constants/fields_constants.dart';
import 'package:admin_dvij/constants/promo_constants.dart';
import 'package:admin_dvij/constants/screen_constants.dart';
import 'package:admin_dvij/constants/simple_users_constants.dart';
import 'package:admin_dvij/dates/date_type.dart';
import 'package:admin_dvij/dates/date_type_picker.dart';
import 'package:admin_dvij/dates/irregular_date.dart';
import 'package:admin_dvij/dates/long_date.dart';
import 'package:admin_dvij/dates/once_date.dart';
import 'package:admin_dvij/places/place_picker.dart';
import 'package:admin_dvij/promos/promo_category_picker.dart';
import 'package:admin_dvij/promos/promo_class.dart';
import 'package:admin_dvij/promos/promos_list_class.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import '../cities/city_class.dart';
import '../cities/city_picker_page.dart';
import '../constants/buttons_constants.dart';
import '../constants/categories_constants.dart';
import '../constants/date_constants.dart';
import '../constants/system_constants.dart';
import '../constants/users_constants.dart';
import '../database/image_picker.dart';
import '../dates/regular_date_class.dart';
import '../design/app_colors.dart';
import '../design/loading_screen.dart';
import '../design_elements/button_state_enum.dart';
import '../design_elements/elements_of_design.dart';
import '../places/place_class.dart';
import '../places/places_list_class.dart';
import '../system_methods/system_methods_class.dart';
import '../users/admin_user/admin_user_class.dart';
import '../users/simple_users/creator_popup.dart';
import '../users/simple_users/simple_user.dart';
import '../users/simple_users/simple_users_list.dart';

class PromoCreateViewEditScreen extends StatefulWidget {

  final Promo? promo;
  final int indexTabPage;

  const PromoCreateViewEditScreen({this.promo, required this.indexTabPage, Key? key}) : super(key: key);

  @override
  State<PromoCreateViewEditScreen> createState() => _PromoCreateViewEditScreenState();
}

class _PromoCreateViewEditScreenState extends State<PromoCreateViewEditScreen> {

  AdminUserClass currentAdminUser = AdminUserClass.empty();

  PlacesList placesList = PlacesList();
  PromosListClass promosList = PromosListClass();
  SimpleUsersList usersList = SimpleUsersList();
  SystemMethodsClass sm = SystemMethodsClass();
  final ImagePickerService imagePickerService = ImagePickerService();

  bool loading = false;
  bool saving = false;
  bool deleting = false;
  bool canEdit = false;

  File? _imageFile;

  Promo editPromo = Promo.empty();
  SimpleUser creator = SimpleUser.empty();

  PromoCategory chosenCategory = PromoCategory.empty();
  City chosenCity = City.empty();

  Place chosenPlace = Place.empty();

  AddressType addressType = AddressType();

  DateType chosenDateType = DateType();

  OnceDate onceDate = OnceDate.empty();
  LongDate longDate = LongDate.empty();
  RegularDate schedule = RegularDate();
  IrregularDate irregularDate = IrregularDate.empty();

  bool chosenCreatedByAdmin = false;

  final TextEditingController headlineController = TextEditingController();
  final TextEditingController descController = TextEditingController();
  final TextEditingController createDateController = TextEditingController();
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

  Future<void> initialization({
    bool fromDb = false
  })async{

    setState(() {
      loading = true;
    });

    // Подгружаем текущего пользователя
    currentAdminUser = await currentAdminUser.getCurrentUser(fromDb: false);

    // Подгружаем список заведений и список пользователей
    await placesList.getDownloadedList(fromDb: fromDb);
    await usersList.getDownloadedList(fromDb: fromDb);

    // Если это создание, то устанавливаем режим редактирования и показ расписания сразу
    if (widget.promo == null){
      canEdit = true;
    }

    // Если редактирование, подгружаем создателя и редактируемое заведение. Устанавливаем расписание
    if (widget.promo != null){
      editPromo = promosList.getEntityFromList(widget.promo!.id);
    }

    // Сбрасываем текстовые поля и выбранные настройки по умолчанию
    setTextFieldsOnDefault();

    setState(() {
      loading = false;
    });

  }

  void navigateToPromosListScreen() {
    sm.popBackToPreviousPageWithResult(context: context, result: editPromo);
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

  void setTextFieldsOnDefault(){
    setState(() {

      creator = usersList.getEntityFromList(editPromo.creatorId);
      chosenPlace = placesList.getEntityFromList(editPromo.placeId);

      chosenCategory = PromoCategory.setCategory(category: editPromo.category);
      chosenCity = City.setCity(city: editPromo.city);

      chosenDateType = DateType.setDateType(dateType: editPromo.dateType);

      chosenCreatedByAdmin = editPromo.createdByAdmin;

      if (editPromo.placeId.isNotEmpty){
        addressType = AddressType(addressTypeEnum: AddressTypeEnum.place);
      } else {
        addressType = AddressType(addressTypeEnum: AddressTypeEnum.address);
      }

      headlineController.text = editPromo.headline;
      descController.text = editPromo.desc;
      createDateController.text = sm.formatDateTimeToHumanView(editPromo.createDate);
      streetController.text = editPromo.street;
      houseController.text = editPromo.house;
      phoneController.text = editPromo.phone;
      whatsappController.text = editPromo.whatsapp;
      telegramController.text = editPromo.telegram;
      instagramController.text = editPromo.instagram;

      schedule = RegularDate.setSchedule(fromDate: editPromo.regularDays);
      onceDate = OnceDate.setOnceDay(fromDate: editPromo.onceDay);
      longDate = LongDate.setLongDate(fromDate: editPromo.longDays);
      irregularDate = IrregularDate.setIrregularDates(fromDate: editPromo.irregularDays);

      _imageFile = null;
    });
  }


  Future<void> chooseCreator() async{
    final results = await sm.getPopup(context: context, page: const CreatorPopup());
    if (results != null){

      setState(() {
        creator = results;
      });
      if (!creator.checkAdminRoleInUser(chosenPlace.id)){
        setState(() {
          chosenPlace = Place.empty();
        });
      }
    }
  }

  Future<void> chooseCity() async{
    final results = await sm.getPopup(context: context, page: const CityPickerPage());
    if (results != null){
      setState(() {
        chosenCity = results;
      });
    }
  }

  Future<void> chooseCategory() async{
    final results = await sm.getPopup(context: context, page: const PromoCategoryPicker());
    if (results != null){
      setState(() {
        chosenCategory = results;
      });
    }
  }

  Future<void> choosePlace() async{
    final results = await sm.getPopup(context: context, page: PlacePicker(creatorId: creator.uid.isNotEmpty ? creator.uid : creator.uid));
    if (results != null){
      setState(() {
        chosenPlace = results;
        streetController.text = chosenPlace.street;
        houseController.text = chosenPlace.house;
        chosenCity = chosenPlace.city;
      });
    }
  }

  Future<void> chooseDateType() async{
    final results = await sm.getPopup(context: context, page: const DateTypePicker());
    if (results != null){
      setState(() {
        chosenDateType = results;
      });

    }
  }

  Future<void> chooseAddressType() async{
    final results = await sm.getPopup(context: context, page: const AddressTypePicker());
    if (results != null){

      setState(() {
        addressType = results;
        if (addressType.addressTypeEnum == AddressTypeEnum.place){
          streetController.text = chosenPlace.street;
          houseController.text = chosenPlace.house;
          chosenCity = chosenPlace.city;
        } else {
          chosenCity = editPromo.city;
          streetController.text = editPromo.street;
          houseController.text = editPromo.house;
          chosenPlace = Place.empty();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600; // Условие для мобильной версии

    return Scaffold(
      appBar: AppBar(
        title: Text(
            widget.promo != null && widget.promo!.headline.isNotEmpty
                ? '${PromoConstants.watchPromo} "${editPromo.headline}"'
                : PromoConstants.createPromo
        ),

        leading: IconButton(
          icon: const Icon(FontAwesomeIcons.chevronLeft, size: 18,),
          onPressed: () {
            navigateToPromosListScreen();
          },
        ),

        actions: [

          // Иконка обновления данных.

          if (widget.promo != null) IconButton(
            onPressed: () async {
              await initialization(fromDb: true);
            },
            icon: const Icon(FontAwesomeIcons.arrowsRotate, size: 15, color: AppColors.white,),
          ),

          // Иконка редактирования. Доступна если у текущего админа есть доступ или это не создание заведения

          if (currentAdminUser.adminRole.accessToEditEvents() && widget.promo != null) IconButton(
            onPressed: () async {
              setState(() {
                canEdit = true;
              });
            },
            icon: const Icon(FontAwesomeIcons.penToSquare, size: 15, color: AppColors.white,),
          ),

          if (currentAdminUser.adminRole.accessToDeleteEvents() && widget.promo != null) IconButton(
            onPressed: () async {
              await deletePromo();
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

                        ElementsOfDesign.imageForEditViewScreen(
                            context: context,
                            imageUrl: editPromo.imageUrl,
                            imageFile: _imageFile,
                            canEdit: canEdit,
                            onEditImage: () async {
                              await _pickImage();
                            }
                        ),

                        const SizedBox(height: 20,),

                        ElementsOfDesign.buildTextField(
                            controller: headlineController,
                            labelText: PromoConstants.namePromo,
                            canEdit: canEdit,
                            icon: FontAwesomeIcons.heading,
                            context: context
                        ),

                        const SizedBox(height: 20,),

                        ElementsOfDesign.buildTextField(
                          controller: descController,
                          labelText: PromoConstants.descPromo,
                          canEdit: canEdit,
                          icon: FontAwesomeIcons.paragraph,
                          context: context,
                          maxLines: null,
                        ),

                        const SizedBox(height: 20,),

                        ElementsOfDesign.buildAdaptiveRow(
                            isMobile: isMobile,
                            children: [

                              chosenCategory.getCategoryFieldWidget(
                                  canEdit: canEdit,
                                  context: context,
                                  onTap: () async {
                                    await chooseCategory();
                                  }
                              ),

                              ElementsOfDesign.checkBox(
                                  text: ScreenConstants.createdByAdminHeadline,
                                  isChecked: chosenCreatedByAdmin,
                                  canEdit: canEdit,
                                  onChanged: (result){
                                    setState(() {
                                      chosenCreatedByAdmin = !chosenCreatedByAdmin;
                                    });
                                  },
                                  context: context
                              )
                            ]
                        ),


                        ElementsOfDesign.buildAdaptiveRow(
                            isMobile: isMobile,
                            children: [
                              if (canEdit) addressType.getAddressTypeFieldWidget(
                                  canEdit: canEdit,
                                  context: context,
                                  onTap: () async {
                                    await chooseAddressType();
                                  }
                              ),

                              chosenCity.getCityWidget(
                                  canEdit: canEdit && addressType.addressTypeEnum == AddressTypeEnum.address,
                                  context: context,
                                  onTap: () async {
                                    await chooseCity();
                                  }
                              ),

                              if (addressType.addressTypeEnum == AddressTypeEnum.place) chosenPlace.getPlaceWidgetField(
                                  canEdit: canEdit,
                                  context: context,
                                  onTap: () async {
                                    await choosePlace();
                                  }
                              ),

                              if (addressType.addressTypeEnum == AddressTypeEnum.address) ElementsOfDesign.buildTextField(
                                  controller: streetController,
                                  labelText: FieldsConstants.streetField,
                                  canEdit: canEdit,
                                  icon: FontAwesomeIcons.streetView,
                                  context: context
                              ),

                              if (addressType.addressTypeEnum == AddressTypeEnum.address) ElementsOfDesign.buildTextField(
                                  controller: houseController,
                                  labelText: FieldsConstants.houseNumberField,
                                  canEdit: canEdit,
                                  icon: FontAwesomeIcons.hashtag,
                                  context: context
                              ),

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
                                  labelText: PromoConstants.createDatePromo,
                                  canEdit: false,
                                  icon: FontAwesomeIcons.calendar,
                                  context: context
                              ),

                              creator.getCreatorWidget(
                                  creator: creator,
                                  onTap: () async {
                                    await chooseCreator();
                                  },
                                  canEdit: canEdit && currentAdminUser.adminRole.accessToEditCreator(),
                                  context: context
                              )
                            ]
                        ),

                        Card(
                          color: AppColors.greyBackground,
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              children: [

                                chosenDateType.getDateTypeWidget(
                                    canEdit: canEdit,
                                    context: context,
                                    onTap: () async {
                                      await chooseDateType();
                                    }
                                ),

                                const SizedBox(height: 20,),

                                if (chosenDateType.dateType == DateTypeEnum.regular) schedule.getRegularEditWidgetTwo(
                                    context: context,
                                    onTapStart: (index) => pickRegularTime(index, true),
                                    onTapEnd: (index) => pickRegularTime(index, false),
                                    canEdit: canEdit,
                                    onClean: (index) {
                                      updateTime(index, true, null);
                                      updateTime(index, false, null);
                                    },
                                    isMobile: isMobile
                                ),

                                const SizedBox(height: 10,),

                                if (chosenDateType.dateType == DateTypeEnum.once) onceDate.getOnceDayWidget(
                                    isMobile: isMobile,
                                    canEdit: canEdit,
                                    context: context,
                                    onDateTap: () async {
                                      await pickOnceLongDate(isStart: true, isOnce: true);
                                    },
                                    onStartTimeTap: () async {
                                      await pickOnceLongTime(isOnce: true, isStart:  true);
                                    },
                                    onEndTimeTap: () async {
                                      await pickOnceLongTime(isOnce: true, isStart:  false);
                                    }
                                ),

                                if (chosenDateType.dateType == DateTypeEnum.long) longDate.getLongDateWidget(
                                    isMobile: isMobile,
                                    canEdit: canEdit,
                                    context: context,
                                    onStartDate: () async {
                                      await pickOnceLongDate(isStart: true, isOnce: false);
                                    },
                                    onEndDate: () async {
                                      await pickOnceLongDate(isStart: false, isOnce: false);
                                    },
                                    onStartTime: () async {
                                      await pickOnceLongTime(isOnce: false, isStart:  true);
                                    },
                                    onEndTime: () async {
                                      await pickOnceLongTime(isOnce: false, isStart:  false);
                                    }
                                ),

                                if (chosenDateType.dateType == DateTypeEnum.irregular) irregularDate.getIrregularDateWidget(
                                    isMobile: isMobile,
                                    canEdit: canEdit,
                                    context: context,
                                    onDateTap: canEdit ? (index) async{
                                      DateTime? picked = await pickIrregularDate(date: irregularDate.dates[index].date);
                                      if (picked != null) {
                                        setState(() {
                                          irregularDate.dates[index].date = picked;
                                        });
                                      }
                                    } : null,
                                    onStartTimeTap: canEdit ? (index) async{
                                      TimeOfDay? picked = await pickIrregularTime(irregularDate.dates[index].startTime);
                                      if (picked != null) {
                                        setState(() {
                                          irregularDate.dates[index].startTime = picked;
                                        });
                                      }
                                    } : null,
                                    onEndTimeTap: canEdit ? (index) async{
                                      TimeOfDay? picked = await pickIrregularTime(irregularDate.dates[index].endTime);
                                      if (picked != null) {
                                        setState(() {
                                          irregularDate.dates[index].endTime = picked;
                                        });
                                      }
                                    } : null,
                                    onRemoveDate: (index) {
                                      setState(() {
                                        irregularDate.dates.remove(irregularDate.dates[index]);
                                      });
                                    },
                                    addDate: (){
                                      setState(() {
                                        irregularDate.dates.add(OnceDate(date: null, startTime: null, endTime: null));
                                      });
                                    }
                                ),
                              ],
                            ),
                          ),
                        ),



                        const SizedBox(height: 20,),

                        if (canEdit) ElementsOfDesign.buildAdaptiveRow(
                            isMobile: isMobile,
                            children: [
                              ElementsOfDesign.customButton(
                                  method: () async {
                                    await savePromo();
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

  Future<void> deletePromo () async {

    bool? result = await ElementsOfDesign.exitDialog(
        context,
        PromoConstants.deletePromoDesc,
        ButtonsConstants.delete,
        ButtonsConstants.cancel,
        PromoConstants.deletePromoHeadline
    );

    if (result != null && result){
      setState(() {
        deleting = true;
      });

      String publishResult = await editPromo.deleteFromDb();

      if (publishResult == SystemConstants.successConst){

        _showSnackBar(EventsConstants.deleteEventSuccess);
        navigateToPromosListScreen();

      } else {
        _showSnackBar(publishResult);
      }

      setState(() {
        saving = false;
      });
    }

  }

  Future<void> savePromo() async{
    setState(() {
      saving = true;
    });

    Promo tempPromo = setPromoBeforeSaving();


    if (checkPromo(tempPromo) == SystemConstants.successConst){

      String publishResult = await tempPromo.publishToDb(_imageFile);

      if (publishResult == SystemConstants.successConst) {

        // Если поменяли создателя
        if (creator.uid != editPromo.creatorId){
          // Подгружаем старого создателя
          SimpleUser previousCreator = usersList.getEntityFromList(editPromo.creatorId);

          // Если прогрузился
          if (previousCreator.uid.isNotEmpty){
            // Удаляем запись об этом мероприятии
            await previousCreator.deletePromoFromMyPromos(promoId: editPromo.id);
          }
        }

        // Если есть выбранное место
        if (chosenPlace.id.isNotEmpty){
          // Если выбрали другое место проведения
          if (chosenPlace.id != editPromo.placeId){
            // Подгружаем место
            Place previousPlace = placesList.getEntityFromList(editPromo.placeId);

            // Если место прогрузилось
            if (previousPlace.id.isNotEmpty){
              // Удаляем мероприятие из заведения
              await previousPlace.deletePromoFromPlace(promoId: editPromo.id);
            }
          }
        }

        await initialization();

        _showSnackBar(PromoConstants.editPromoSuccess);

        canEdit = false;
        setTextFieldsOnDefault();

        if (widget.promo == null){
          navigateToPromosListScreen();
        }

      } else {
        _showSnackBar(publishResult);
      }
    } else {
      _showSnackBar(checkPromo(tempPromo));
    }

    setState(() {
      saving = false;
    });
  }

  void _showSnackBar(String message){
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  String checkPromo(Promo tempPromo){

    if (tempPromo.headline.isEmpty){
      return PromoConstants.noNameError;
    }
    if (tempPromo.desc.isEmpty){
      return PromoConstants.noDescError;
    }
    if (tempPromo.creatorId.isEmpty){
      return SimpleUsersConstants.creatorNotChosenError;
    }

    if (tempPromo.city.id.isEmpty){
      return CityConstants.noChosenCityError;
    }
    if (tempPromo.category.id.isEmpty){
      return CategoriesConstants.categoryNotChosen;
    }
    if (tempPromo.street.isEmpty){
      return ErrorConstants.noStreetError;
    }

    if (tempPromo.house.isEmpty){
      return ErrorConstants.noStreetError;
    }

    if (tempPromo.phone.isEmpty){
      return ErrorConstants.noPhone;
    }

    if (addressType.addressTypeEnum == AddressTypeEnum.place){
      if (tempPromo.placeId.isEmpty){
        return ErrorConstants.noChosenPlaceError;
      }
    } else if (addressType.addressTypeEnum == AddressTypeEnum.notChosen){
      return ErrorConstants.noChosenAddressType;
    }

    if (tempPromo.dateType.dateType == DateTypeEnum.notChosen){
      return ErrorConstants.noChosenDateType;
    } else if (tempPromo.dateType.dateType == DateTypeEnum.once){
      if (tempPromo.onceDay.checkDate() != SystemConstants.successConst){
        return tempPromo.onceDay.checkDate();
      }
    } else if (tempPromo.dateType.dateType == DateTypeEnum.long){
      if (tempPromo.longDays.checkDate() != SystemConstants.successConst){
        return tempPromo.longDays.checkDate();
      }
    } else if (tempPromo.dateType.dateType == DateTypeEnum.regular){
      if (!schedule.checkRegularDate()){
        return ErrorConstants.scheduleNotHaveInputTime;
      }
    } else if (tempPromo.dateType.dateType == DateTypeEnum.irregular){
      if (tempPromo.irregularDays.checkDate() != SystemConstants.successConst){
        return tempPromo.irregularDays.checkDate();
      }
    }

    return SystemConstants.successConst;

  }

  Promo setPromoBeforeSaving(){

    Promo tempPromo = Promo.empty();

    tempPromo.id = editPromo.id;

    tempPromo.dateType = chosenDateType;

    if (chosenDateType.dateType == DateTypeEnum.once){
      tempPromo.onceDay = onceDate;
    } else if (chosenDateType.dateType == DateTypeEnum.long){
      tempPromo.longDays = longDate;
    } else if (chosenDateType.dateType == DateTypeEnum.regular){
      tempPromo.regularDays = schedule;
    } else if (chosenDateType.dateType == DateTypeEnum.irregular){
      tempPromo.irregularDays = irregularDate;
    }

    tempPromo.headline = headlineController.text;
    tempPromo.desc = descController.text;
    tempPromo.creatorId = creator.uid;
    tempPromo.createDate = editPromo.createDate;
    tempPromo.category = chosenCategory;
    tempPromo.city = chosenCity;
    tempPromo.street = streetController.text;
    tempPromo.house = houseController.text;
    tempPromo.phone = phoneController.text;
    tempPromo.whatsapp = whatsappController.text;
    tempPromo.instagram = instagramController.text;
    tempPromo.telegram = telegramController.text;
    tempPromo.imageUrl = editPromo.imageUrl;
    tempPromo.placeId = chosenPlace.id;
    tempPromo.createdByAdmin = chosenCreatedByAdmin;

    return tempPromo;

  }

  /// Обновляем время
  void updateTime(int index, bool isStart, TimeOfDay? newTime) {
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
  Future<void> pickRegularTime(int index, bool isStart) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: schedule.getTime(index: index, isStart: true) ?? TimeOfDay.now(),
      initialEntryMode: TimePickerEntryMode.dial,
    );
    if (picked != null) {
      updateTime(index, isStart, picked);
    }
  }

  /// Показ диалога выбора времени
  Future<void> pickOnceLongTime({
    required bool isStart,
    required bool isOnce
  }) async {

    TimeOfDay initial = TimeOfDay.now();

    // Устанавливаем initial
    // Если это начальная дата
    if (isStart){
      // Если одиночная дата
      if (isOnce){
        if (onceDate.startTime != null) {
          initial = onceDate.startTime!;
        }
      }
      // Если долгая дата
      else {
        if (longDate.startTime != null) {
          initial = longDate.startTime!;
        }
      }

    }
    // Если это конечная дата
    else {
      // Если одиночная дата
      if (isOnce){
        if (onceDate.endTime != null) {
          initial = onceDate.endTime!;
        }
      }
      // Если долгая дата
      else {
        if (longDate.endTime != null) {
          initial = longDate.endTime!;
        }
      }
    }

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initial,
      initialEntryMode: TimePickerEntryMode.dial,
    );
    if (picked != null) {
      setState(() {
        if (isStart){
          if (isOnce){
            onceDate.startTime = picked;
          } else {
            longDate.startTime = picked;
          }
        } else {
          if (isOnce) {
            onceDate.endTime = picked;
          } else {
            longDate.endTime = picked;
          }
        }
      });
    }
  }

  /// Показ диалога выбора времени
  Future<TimeOfDay?> pickIrregularTime(TimeOfDay? time) async {

    TimeOfDay initial = TimeOfDay.now();

    if (time != null) {
      initial = time;
    }

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initial,
      initialEntryMode: TimePickerEntryMode.dial,
    );
    if (picked != null) {
      return picked;
    }

    return null;
  }

  Future<DateTime?> pickIrregularDate({required DateTime? date}) async{
    DateTime firstDate = DateTime.now();

    if (date != null){
      firstDate = date;
    }

    final DateTime? pickedDate = await sm.dataPicker(
        context: context,
        label: DateConstants.onceDayDateChoose,
        firstDate: firstDate,
        lastDate: DateTime(2050),
        currentDate: date
    );

    if (pickedDate != null){
      return pickedDate;
    }

    return null;
  }

  Future<void> pickOnceLongDate({required isOnce, required bool isStart}) async{
    DateTime firstDate = DateTime.now();
    DateTime? lastDate;

    DateTime currentDate = DateTime.now();

    if (isOnce){
      if (onceDate.date != null){
        firstDate = onceDate.date!;
        currentDate = onceDate.date!;
      }
    } else {
      // Устанавливаем границы выбора дат в зависимости от выбранного типа (isStart)
      if (isStart) {
        currentDate = longDate.startDate ?? DateTime.now();
        lastDate = longDate.endDate ?? DateTime(2050); // Дата завершения должна быть границей
      } else {
        currentDate = longDate.endDate ?? longDate.startDate ?? DateTime.now();
        firstDate = longDate.startDate ?? DateTime.now(); // Дата начала должна быть границей
        lastDate = DateTime(2050);
      }
    }

    final DateTime? pickedDate = await sm.dataPicker(
        context: context,
        label: DateConstants.onceDayDateChoose,
        firstDate: firstDate,
        lastDate: lastDate ?? DateTime(2050),
        currentDate: currentDate
    );

    if (pickedDate != null){
      setState(() {
        if (isOnce){
          onceDate.date = pickedDate;
        } else {
          if (isStart) {
            longDate.startDate = pickedDate;
          } else {
            longDate.endDate = pickedDate;
          }
        }
      });
    }
  }

}
