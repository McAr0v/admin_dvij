import 'dart:io';
import 'package:admin_dvij/auth/log_in_screen.dart';
import 'package:admin_dvij/constants/admins_constants.dart';
import 'package:admin_dvij/constants/city_constants.dart';
import 'package:admin_dvij/constants/date_constants.dart';
import 'package:admin_dvij/constants/screen_constants.dart';
import 'package:admin_dvij/design/loading_screen.dart';
import 'package:admin_dvij/design_elements/button_state_enum.dart';
import 'package:admin_dvij/navigation/drawer_custom.dart';
import 'package:admin_dvij/system_methods/system_methods_class.dart';
import 'package:admin_dvij/users/admin_user/admin_users_list.dart';
import 'package:admin_dvij/users/genders/gender_picker.dart';
import 'package:admin_dvij/users/roles/admin_picker.dart';
import 'package:admin_dvij/users/roles/admins_roles_class.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import '../../cities/city_class.dart';
import '../../cities/city_picker_page.dart';
import '../../constants/buttons_constants.dart';
import '../../constants/system_constants.dart';
import '../../constants/users_constants.dart';
import '../../database/image_picker.dart';
import '../../design/app_colors.dart';
import '../../design_elements/elements_of_design.dart';
import 'admin_user_class.dart';
import '../genders/gender_class.dart';


/// Если это страница ТЕКУЩЕГО ПОЛЬЗОВАТЕЛЯ, то передавать админа не надо
class ProfileScreen extends StatefulWidget {

  final AdminUserClass? admin;
  final bool isCreate;

  const ProfileScreen({this.admin, this.isCreate = false, Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  // Текущий админ, который вносит изменения. Может редактировать сам себя
  AdminUserClass currentUserAdmin = AdminUserClass.empty();

  // Редактируемый пользователь. Может быть другой, отличный от текущего пользователя
  AdminUserClass editUserAdmin = AdminUserClass.empty();

  SystemMethodsClass systemMethods = SystemMethodsClass();
  final ImagePickerService imagePickerService = ImagePickerService();
  AdminUsersListClass adminsListClass = AdminUsersListClass();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController lastnameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController birthDateController = TextEditingController();
  final TextEditingController adminRoleController = TextEditingController();
  final TextEditingController adminGenderController = TextEditingController();
  final TextEditingController imageController = TextEditingController();

  // Переменные для сохранения данных при смене значения
  // На случай, если пользователь отменит редактирование, вернутся значения по умолчанию
  City chosenCityOnEdit = City.empty();
  DateTime selectedBirthDateOnEdit = DateTime(2100);
  AdminRoleClass chosenAdminRole = AdminRoleClass(AdminRole.notChosen);
  Gender chosenAdminGender = Gender();
  File? _imageFile;

  bool loading = false;
  bool logOuting = false;
  bool saving = false;

  bool canEdit = false;

  @override
  void initState() {
    getAdminsInfo();
    super.initState();
  }

  void setTextFieldsOnDefault(){
    setState(() {
      emailController.text = editUserAdmin.email;
      nameController.text = editUserAdmin.name;
      lastnameController.text = editUserAdmin.lastName;
      phoneController.text = editUserAdmin.phone;
      cityController.text = editUserAdmin.city.name.isNotEmpty ? editUserAdmin.city.name : CityConstants.cityNotChosen;
      birthDateController.text = editUserAdmin.birthDate.year != 2100 ? editUserAdmin.formatBirthDateTime() : DateConstants.noDate ;
      adminRoleController.text = editUserAdmin.adminRole.getNameOrDescOfRole(true);
      adminGenderController.text = editUserAdmin.gender.toString(needTranslate: true);
      chosenCityOnEdit = City.empty();
      selectedBirthDateOnEdit = DateTime(2100);
      chosenAdminRole = AdminRoleClass(AdminRole.notChosen);
      chosenAdminGender = Gender();
      _imageFile = null;
    });
  }

  void setEditAdminBeforeSaving(){

    if (editUserAdmin.adminRole.adminRole != AdminRole.creator && chosenAdminRole.adminRole != AdminRole.notChosen){
      editUserAdmin.adminRole = chosenAdminRole;
    }

    if (chosenAdminGender.gender != GenderEnum.notChosen){
      editUserAdmin.gender = chosenAdminGender;
    }

    if (selectedBirthDateOnEdit.year != 2100){
      editUserAdmin.birthDate = selectedBirthDateOnEdit;
    }

    if (chosenCityOnEdit.id.isNotEmpty){
      editUserAdmin.city = chosenCityOnEdit;
    }

    editUserAdmin.phone = phoneController.text;
    editUserAdmin.name = nameController.text;
    editUserAdmin.lastName = lastnameController.text;

  }

  Future<void> getAdminsInfo({bool fromDB = false}) async{
    setState(() {
      loading = true;
    });

    // Подгружаем текущего пользователя
    currentUserAdmin = await currentUserAdmin.getCurrentUser(fromDb: fromDB);

    // Если пользователь не передан, значит пользователь редактирует сам себя
    if (widget.admin == null) {
      // подгружаем данные в переменную редактируемого пользователя
      editUserAdmin = currentUserAdmin;
    } else if (
        widget.admin != null
        && widget.isCreate
        && adminsListClass.getAdminRoleFromList(widget.admin!.uid).adminRole == AdminRole.notChosen
    ) {
      // Если админа создают, то передаем ему переданного пользователя
      editUserAdmin = widget.admin!;
    } else {
      // Если пользователь редактирует не себя, то подружаем данные из сохраненного списка пользователей
      editUserAdmin = await editUserAdmin.getUserFromDownloadedList(uid: widget.admin!.uid, fromDb: fromDB);
    }

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
            widget.admin == null
                ? ScreenConstants.profilePage
                : !widget.isCreate
                ? '${ScreenConstants.profilePage} ${editUserAdmin.getFullName()}'
                : AdminConstants.createAdminHeadline
        ),

        // Если пользователь редактирует не себя, то вместо Drawer ставим иконку возвращения
        // на предыдущий экран

        leading: widget.admin != null ? IconButton(
          icon: const Icon(FontAwesomeIcons.chevronLeft, size: 18,),
          onPressed: () {
            systemMethods.popBackToPreviousPageWithResult(context: context, result: true);
          },
        ) : null,

        actions: [

          // Иконка обновления данных. Доступна если это не создание пользователя

          IconButton(
            onPressed: () async {
              await getAdminsInfo(fromDB: true);
            },
            icon: const Icon(FontAwesomeIcons.arrowsRotate, size: 15, color: AppColors.white,),
          ),

          // Иконка редактирования. Доступна если у текущего пользователя есть доступ
          // Или редактируемый пользователь и есть текущий пользователь
          // И если редактируемый пользователь не создатель
          // Или текущий пользователь создатель
          // Т.е супер админ может зайти отредактировать всех, кроме создателя
          // Создатель может вообще всех отредактировать
          // Любой другой не сможет никого отредактировать, кроме себя самого

          if (
          (
              currentUserAdmin.adminRole.accessToEditUsers()
              || currentUserAdmin.uid == editUserAdmin.uid
          )
              && (
              editUserAdmin.adminRole.accessToEditingCurrentAdminUser()
                  || currentUserAdmin.adminRole.accessToAll()
          )

          ) IconButton(
            onPressed: () async {
              setState(() {
                canEdit = true;
              });
            },
            icon: const Icon(FontAwesomeIcons.penToSquare, size: 15, color: AppColors.white,),
          ),

          // Иконка выхода из профиля. Доступна только если пользователь редактирует себя

          if (currentUserAdmin.uid == editUserAdmin.uid) IconButton(
            onPressed: () async {
              _singOut();
            },
            icon: const Icon(FontAwesomeIcons.arrowRightFromBracket, size: 15, color: AppColors.white,),
          ),

        ],
      ),
      body: Stack(
        children: [
          if (loading) const LoadingScreen(loadingText: SystemConstants.loadingDefault)
          else if (logOuting) const LoadingScreen(loadingText: SystemConstants.logOut)
          else if (saving) const LoadingScreen(loadingText: SystemConstants.saving)
          else SingleChildScrollView(
            child: Center(
              child: Column(
                children: [
                  Container(
                    width: systemMethods.getScreenWidth(),
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
                        editUserAdmin.getInfoWidgetForProfile(context: context, imageFile: _imageFile),

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
                                  controller: cityController,
                                  labelText: UserConstants.city,
                                  canEdit: canEdit,
                                  icon: FontAwesomeIcons.mapLocation,
                                  context: context,
                                  readOnly: true,
                                  onTap: () async {
                                    await showCityTwoPopup();
                                  },
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
                                controller: adminRoleController,
                                labelText: UserConstants.adminRole,
                                canEdit: canEditRole(),
                                icon: FontAwesomeIcons.userGear,
                                context: context,
                                readOnly: true,
                                onTap: () async {
                                  await showRolePopup();
                                },
                              ),
                              ElementsOfDesign.buildTextField(
                                controller: adminGenderController,
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
                                  await saveAdmin();
                                },
                                textOnButton: ButtonsConstants.save,
                                context: context,
                              ),
                        ]),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      drawer: const CustomDrawer(),
    );
  }

  Future<void> saveAdmin() async{
    setState(() {
      saving = true;
    });

    setEditAdminBeforeSaving();

    String publishResult = await editUserAdmin.publishToDb(_imageFile);

    if (publishResult == SystemConstants.successConst) {
      _showSnackBar(AdminConstants.saveSuccess);
      await getAdminsInfo(fromDB: false);
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

  bool canEditRole(){
    if(editUserAdmin.adminRole.adminRole == AdminRole.creator) {
      return false;
    } else {
      return canEdit && currentUserAdmin.adminRole.accessToEditUsers();
    }
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
        chosenAdminGender = result;
        adminGenderController.text = chosenAdminGender.toString(needTranslate: true);
      });

    }

  }

  Future<void> showRolePopup() async{
    dynamic result = await showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return const AdminPicker();
      },
    );

    if (result != null) {

      setState(() {
        chosenAdminRole = result;
        adminRoleController.text = chosenAdminRole.getNameOrDescOfRole(true);
      });

    }

  }

  Future<void> showCityTwoPopup() async{
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
    DateTime initial = editUserAdmin.birthDate.year != 2100 ? editUserAdmin.birthDate : DateTime.now();
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

    if (picked != null && picked != editUserAdmin.birthDate) {
      setState(() {
        selectedBirthDateOnEdit = picked;
        birthDateController.text = systemMethods.formatDateTimeToHumanView(selectedBirthDateOnEdit);
      });
    }

  }

  void _singOut() async {

    bool? confirmed = await ElementsOfDesign.exitDialog(
        context,
        AdminConstants.signOutDesc,
        ButtonsConstants.logOut,
        ButtonsConstants.cancel,
        AdminConstants.signOutHeadline
    );

    if (confirmed != null && confirmed) {
      setState(() {
        logOuting = true;
      });
      String? signOut = await currentUserAdmin.signOut();
      if (signOut == SystemConstants.successConst){
        await navigateToLogIn();
      }
      setState(() {
        logOuting = false;
      });
    }
  }

  Future<void> navigateToLogIn()async {
    await systemMethods.pushAndDeletePreviousPages(context: context, page: const LogInScreen());
  }
}
