import 'dart:io';
import 'package:admin_dvij/constants/city_constants.dart';
import 'package:admin_dvij/constants/date_constants.dart';
import 'package:admin_dvij/constants/simple_users_constants.dart';
import 'package:admin_dvij/places/place_class.dart';
import 'package:admin_dvij/places/places_list_class.dart';
import 'package:admin_dvij/users/simple_users/simple_user.dart';
import 'package:admin_dvij/users/simple_users/simple_users_list.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import '../../cities/city_class.dart';
import '../../cities/city_picker_page.dart';
import '../../constants/buttons_constants.dart';
import '../../constants/screen_constants.dart';
import '../../constants/system_constants.dart';
import '../../constants/users_constants.dart';
import '../../database/image_picker.dart';
import '../../design/app_colors.dart';
import '../../design/loading_screen.dart';
import '../../design_elements/button_state_enum.dart';
import '../../design_elements/elements_of_design.dart';
import '../../system_methods/system_methods_class.dart';
import '../admin_user/admin_user_class.dart';
import '../genders/gender_class.dart';
import '../genders/gender_picker.dart';

class SimpleUserScreen extends StatefulWidget {
  final SimpleUser simpleUser;
  const SimpleUserScreen({required this.simpleUser, Key? key}) : super(key: key);

  @override
  State<SimpleUserScreen> createState() => _SimpleUserScreenState();
}

class _SimpleUserScreenState extends State<SimpleUserScreen> {

  // Текущий админ, который вносит изменения.
  AdminUserClass currentUserAdmin = AdminUserClass.empty();

  // Редактируемый пользователь.
  SimpleUser editUser = SimpleUser.empty();

  SystemMethodsClass systemMethods = SystemMethodsClass();
  final ImagePickerService imagePickerService = ImagePickerService();
  SimpleUsersList usersListsClass = SimpleUsersList();
  PlacesList placesList = PlacesList();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController lastnameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController birthDateController = TextEditingController();
  final TextEditingController genderController = TextEditingController();
  final TextEditingController whatsappController = TextEditingController();
  final TextEditingController telegramController = TextEditingController();
  final TextEditingController instagramController = TextEditingController();
  final TextEditingController imageController = TextEditingController();

  // Переменные для сохранения данных при смене значения
  // На случай, если пользователь отменит редактирование, вернутся значения по умолчанию
  City chosenCityOnEdit = City.empty();
  DateTime selectedBirthDateOnEdit = DateTime(2100);
  Gender chosenGender = Gender();
  File? _imageFile;
  List<Place> userPlaces = [];


  bool showPlaces = false;

  bool loading = false;
  bool logOuting = false;
  bool saving = false;

  bool canEdit = false;

  @override
  void initState() {
    getUsersInfo();
    super.initState();
  }

  void setTextFieldsOnDefault(){
    setState(() {
      emailController.text = editUser.email;
      nameController.text = editUser.name;
      lastnameController.text = editUser.lastName;
      phoneController.text = editUser.phone;
      cityController.text = editUser.city.name.isNotEmpty ? editUser.city.name : CityConstants.cityNotChosen;
      birthDateController.text = editUser.birthDate.year != 2100 ? editUser.formatBirthDateTime() : DateConstants.noDate ;
      genderController.text = editUser.gender.toString(needTranslate: true);
      chosenCityOnEdit = City.empty();
      selectedBirthDateOnEdit = DateTime(2100);
      instagramController.text = editUser.instagram;
      whatsappController.text = editUser.whatsapp;
      telegramController.text = editUser.telegram;
      chosenGender = Gender();
      _imageFile = null;
    });
  }

  void setEditUserBeforeSaving(){

    if (chosenGender.gender != GenderEnum.notChosen){
      editUser.gender = chosenGender;
    }

    if (selectedBirthDateOnEdit.year != 2100){
      editUser.birthDate = selectedBirthDateOnEdit;
    }

    if (chosenCityOnEdit.id.isNotEmpty){
      editUser.city = chosenCityOnEdit;
    }

    editUser.phone = phoneController.text;
    editUser.name = nameController.text;
    editUser.lastName = lastnameController.text;
    editUser.instagram = instagramController.text;
    editUser.telegram = telegramController.text;
    editUser.whatsapp = whatsappController.text;

  }

  Future<void> getUsersInfo({bool fromDB = false}) async{
    setState(() {
      loading = true;
    });

    // Подгружаем текущего админа
    currentUserAdmin = await currentUserAdmin.getCurrentUser(fromDb: fromDB);

    editUser = await editUser.getUserFromDownloadedList(uid: widget.simpleUser.uid, fromDb: fromDB);

    userPlaces = await placesList.getPlacesListFromSimpleUser(placesList: editUser.placesList);

    // Сбрасываем значения переменных для изменений в исходное состояние
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
            '${ScreenConstants.profilePage} ${editUser.getFullName()}'
        ),

        leading: IconButton(
          icon: const Icon(FontAwesomeIcons.chevronLeft, size: 18,),
          onPressed: () {
            systemMethods.popBackToPreviousPageWithResult(context: context, result: true);
          },
        ),

        actions: [

          // Иконка обновления данных.

          IconButton(
            onPressed: () async {
              await getUsersInfo(fromDB: true);
            },
            icon: const Icon(FontAwesomeIcons.arrowsRotate, size: 15, color: AppColors.white,),
          ),

          // Иконка редактирования. Доступна если у текущего админа есть доступ

          if (currentUserAdmin.adminRole.accessToEditUsers()) IconButton(
            onPressed: () async {
              setState(() {
                canEdit = true;
              });
            },
            icon: const Icon(FontAwesomeIcons.penToSquare, size: 15, color: AppColors.white,),
          ),

        ],
      ),
      body: Stack(
        children: [
          if (loading) const LoadingScreen(loadingText: SystemConstants.loadingDefault)
          else if (saving) const LoadingScreen(loadingText: SystemConstants.saving)
            else SingleChildScrollView(
                child: Center(
                  child: Column(
                    children: [
                      Container(
                        width: systemMethods.getScreenWidth(neededWidth: 800),
                        padding: const EdgeInsets.all(30),
                        margin: EdgeInsets.symmetric(
                            vertical: Platform.isWindows || Platform.isMacOS ? 20 : 10,
                            horizontal: Platform.isWindows || Platform.isMacOS ? 0 : 10
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.greyOnBackground,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            // Виджет с аватаром и информацией о пользователе
                            editUser.getInfoWidgetForProfile(context: context, imageFile: _imageFile),

                            if (canEdit) const SizedBox(height: 5,),

                            // Кнопка - изменить фотографию
                            if (canEdit) ElementsOfDesign.linkButton(
                                method: ()async{
                                  await _pickImage();
                                },
                                text: ButtonsConstants.changePhoto,
                                context: context
                            ),

                            const SizedBox(height: 40,),

                            ElementsOfDesign.buildAdaptiveRow(
                                isMobile,
                                [
                                  ElementsOfDesign.buildTextField(
                                      controller: nameController,
                                      labelText: UserConstants.name,
                                      canEdit: canEdit,
                                      icon: FontAwesomeIcons.idBadge,
                                      context: context
                                  ),
                                  ElementsOfDesign.buildTextField(
                                      controller: lastnameController,
                                      labelText: UserConstants.lastName,
                                      canEdit: canEdit,
                                      icon: FontAwesomeIcons.idBadge,
                                      context: context
                                  )

                                ]
                            ),

                            ElementsOfDesign.buildAdaptiveRow(
                                isMobile,
                                [
                                  ElementsOfDesign.buildTextField(
                                      controller: emailController,
                                      labelText: UserConstants.email,
                                      canEdit: false,
                                      icon: FontAwesomeIcons.envelope,
                                      context: context
                                  ),
                                  ElementsOfDesign.buildTextField(
                                      controller: phoneController,
                                      labelText: UserConstants.phone,
                                      canEdit: canEdit,
                                      icon: FontAwesomeIcons.phone,
                                      context: context
                                  )

                                ]
                            ),

                            ElementsOfDesign.buildAdaptiveRow(
                                isMobile,
                                [
                                  ElementsOfDesign.buildTextField(
                                      controller: whatsappController,
                                      labelText: UserConstants.whatsapp,
                                      canEdit: canEdit,
                                      icon: FontAwesomeIcons.whatsapp,
                                      context: context
                                  ),
                                  ElementsOfDesign.buildTextField(
                                      controller: telegramController,
                                      labelText: UserConstants.telegram,
                                      canEdit: canEdit,
                                      icon: FontAwesomeIcons.telegram,
                                      context: context
                                  )

                                ]
                            ),

                            ElementsOfDesign.buildAdaptiveRow(
                                isMobile,
                                [
                                  ElementsOfDesign.buildTextField(
                                      controller: instagramController,
                                      labelText: UserConstants.instagram,
                                      canEdit: canEdit,
                                      icon: FontAwesomeIcons.instagram,
                                      context: context
                                  ),
                                  ElementsOfDesign.buildTextField(
                                    controller: birthDateController,
                                    labelText: UserConstants.birthDate,
                                    canEdit: canEdit,
                                    icon: FontAwesomeIcons.cakeCandles,
                                    context: context,
                                    readOnly: true,
                                    onTap: () async {
                                      await _selectDate(context);
                                    },
                                  )

                                ]
                            ),

                            ElementsOfDesign.buildAdaptiveRow(
                                isMobile,
                                [
                                  ElementsOfDesign.buildTextField(
                                    controller: cityController,
                                    labelText: UserConstants.city,
                                    canEdit: canEdit,
                                    icon: FontAwesomeIcons.mapLocation,
                                    context: context,
                                    readOnly: true,
                                    onTap: () async {
                                      await showCityPopup();
                                    },
                                  ),

                                  ElementsOfDesign.buildTextField(
                                    controller: genderController,
                                    labelText: UserConstants.gender,
                                    canEdit: canEdit,
                                    icon: FontAwesomeIcons.marsAndVenus,
                                    context: context,
                                    readOnly: true,
                                    onTap: () {
                                      genderPopup();
                                    },
                                  )

                                ]
                            ),

                            if (canEdit) const SizedBox(height: 20,),

                            // Кнопки СОХРАНИТЬ / ОТМЕНИТЬ

                            if (canEdit) ElementsOfDesign.buildAdaptiveRow(
                                isMobile,
                                [
                                  ElementsOfDesign.customButton(
                                      method: (){
                                        canEdit = false;
                                        setTextFieldsOnDefault();
                                      },
                                      textOnButton: ButtonsConstants.cancel,
                                      context: context,
                                      buttonState: ButtonStateEnum.secondary
                                  ),

                                  ElementsOfDesign.customButton(
                                    method: () async{
                                      await saveUser();
                                    },
                                    textOnButton: ButtonsConstants.save,
                                    context: context,
                                  ),
                                ]
                            ),

                            GestureDetector(
                              onTap: (){
                                setState(() {
                                  showPlaces = !showPlaces;
                                });
                              },
                              child: Card(
                                color: AppColors.greyBackground,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [

                                      Row(
                                        children: [
                                          Expanded(
                                            child: Padding(
                                              padding: const EdgeInsets.all(20.0),
                                              child: Text('Заведения пользователя (${userPlaces.length})', style: Theme.of(context).textTheme.bodyMedium,),
                                            ),
                                          ),
                                          IconButton(
                                              onPressed: (){
                                                setState(() {
                                                  showPlaces = !showPlaces;
                                                });
                                              },
                                              icon: Icon(showPlaces ? FontAwesomeIcons.chevronDown : FontAwesomeIcons.chevronRight, size: 15,)
                                          )
                                        ],
                                      ),

                                      if (userPlaces.isNotEmpty && showPlaces) for (Place temp in userPlaces) Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 5),
                                        child: Card(
                                          color: AppColors.greyOnBackground,
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                                            child: Row(
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                ElementsOfDesign.imageWithTags(
                                                  imageUrl: temp.imageUrl,
                                                  width: 100, //Platform.isWindows || Platform.isMacOS ? 100 : double.infinity,
                                                  height: 100,
                                                ),
                                                const SizedBox(width: 10,),
                                                Expanded(
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text(temp.name),
                                                        Text(temp.getAddress(), style: Theme.of(context).textTheme.labelMedium!.copyWith(color: AppColors.greyText),),
                                                        const SizedBox(height: 10),
                                                        Text(
                                                          temp.getCurrentPlaceAdmin(adminsList: editUser.placesList).placeRole.toString(needTranslate: true),
                                                          style: Theme.of(context).textTheme.labelMedium!.copyWith(color: AppColors.greyText),
                                                        ),
                                                      ],
                                                    )
                                                ),
                                                //const SizedBox(width: 20,),

                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),


                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
        ],
      ),
    );
  }

  Future<void> saveUser() async{
    setState(() {
      saving = true;
    });

    setEditUserBeforeSaving();

    String publishResult = await editUser.publishToDb(_imageFile);

    if (publishResult == SystemConstants.successConst) {
      _showSnackBar(SimpleUsersConstants.saveSuccess);
      await getUsersInfo(fromDB: false);
      canEdit = false;
      setTextFieldsOnDefault();
    } else {
      _showSnackBar(publishResult);
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

  Future<void> _pickImage() async {

    final File? pickedImage = await imagePickerService.pickImage(ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        _imageFile = pickedImage;
        imageController.text = _imageFile!.path;
      });
    }
  }

  void genderPopup() async{
    dynamic result = await showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return const GenderPicker();
      },
    );

    if (result != null) {

      setState(() {
        chosenGender = result;
        genderController.text = chosenGender.toString(needTranslate: true);
      });

    }

  }

  Future<void> showCityPopup() async{
    dynamic result = await showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return const CityPickerPage();
      },
    );

    if (result != null) {

      setState(() {
        chosenCityOnEdit = result;
        cityController.text = chosenCityOnEdit.name;
      });

    }

  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime initial = editUser.birthDate.year != 2100 ? editUser.birthDate : DateTime.now();
    if (selectedBirthDateOnEdit.year != 2100) initial = selectedBirthDateOnEdit;

    final DateTime? picked = await showDatePicker(

      locale: const Locale('ru'), // Локализация (например, русский)
      context: context,
      initialDate: initial,
      firstDate: DateTime(1930),
      lastDate: DateTime.now(),
      helpText: DateConstants.chosenDate,
      cancelText: ButtonsConstants.cancel,
      confirmText: ButtonsConstants.ok,
      keyboardType: TextInputType.datetime,
      initialEntryMode: DatePickerEntryMode.inputOnly,
      fieldLabelText: DateConstants.yourBirthdayDate,


    );

    if (picked != null && picked != editUser.birthDate) {
      setState(() {
        selectedBirthDateOnEdit = picked;
        birthDateController.text = systemMethods.formatDateTimeToHumanView(selectedBirthDateOnEdit);
      });
    }

  }
}
