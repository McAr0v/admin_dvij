import 'dart:io';
import 'package:admin_dvij/auth/log_in_screen.dart';
import 'package:admin_dvij/constants/admins_constants.dart';
import 'package:admin_dvij/constants/screen_constants.dart';
import 'package:admin_dvij/design/loading_screen.dart';
import 'package:admin_dvij/design_elements/button_state_enum.dart';
import 'package:admin_dvij/navigation/drawer_custom.dart';
import 'package:admin_dvij/system_methods/system_methods_class.dart';
import 'package:admin_dvij/users/genders/gender_picker.dart';
import 'package:admin_dvij/users/roles/admin_picker.dart';
import 'package:admin_dvij/users/roles/admins_roles_class.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import '../cities/city_class.dart';
import '../cities/city_picker_page.dart';
import '../constants/buttons_constants.dart';
import '../constants/system_constants.dart';
import '../database/image_picker.dart';
import '../database/image_uploader.dart';
import '../design/app_colors.dart';
import '../design_elements/elements_of_design.dart';
import '../users/admin_user/admin_user_class.dart';
import '../users/genders/gender_class.dart';

class ProfileScreen extends StatefulWidget {

  final AdminUserClass? admin;

  const ProfileScreen({this.admin, Key? key}) : super(key: key);

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
  final ImageUploader imageUploader = ImageUploader();

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
      cityController.text = editUserAdmin.city.name;
      birthDateController.text = editUserAdmin.formatBirthDateTime();
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

    // Если пользователь не передан, значит пользователь редактируем сам себя
    if (widget.admin == null) {
      // подгружаем данные в переменную редактируемого пользователя
      editUserAdmin = currentUserAdmin;
    } else {
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
        title: Text(widget.admin == null ? ScreenConstants.profilePage : '${ScreenConstants.profilePage} ${editUserAdmin.getFullName()}'),
        leading: widget.admin != null ? IconButton(
          icon: const Icon(FontAwesomeIcons.chevronLeft, size: 18,),
          onPressed: () {
            Navigator.of(context).pop(true);
          },
        ) : null,

        actions: [

          if (editUserAdmin.uid.isNotEmpty) IconButton(
            onPressed: () async {
              await getAdminsInfo(fromDB: true);
            },
            icon: const Icon(FontAwesomeIcons.arrowsRotate, size: 15, color: AppColors.white,),
          ),

          // Иконка редактирования. Доступна если у текущего пользователя есть доступ
          // Или редактируемый пользователь и есть текущий пользователь

          if ((currentUserAdmin.adminRole.accessToEditUsers() || currentUserAdmin.uid == editUserAdmin.uid) && editUserAdmin.uid.isNotEmpty) IconButton(
            onPressed: () async {

              setState(() {
                canEdit = true;
              });

            },
            icon: const Icon(FontAwesomeIcons.penToSquare, size: 15, color: AppColors.white,),
          ),
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
          else if (logOuting) const LoadingScreen(loadingText: 'Выход из аккаунта')
          else if (saving) const LoadingScreen(loadingText: 'Сохранение изменений')
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
                      color: AppColors.greyOnBackground, // Цвет фона
                      borderRadius: BorderRadius.circular(20), // Скругление углов
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        Row(
                          children: [

                            CircleAvatar(
                              radius: 40,
                              backgroundColor: Colors.grey, // Цвет фона, который будет виден во время загрузки
                              child: ClipOval(
                                child: _imageFile != null
                                    ? Image.file(
                                  _imageFile!,
                                  fit: BoxFit.cover,
                                  width: 100,
                                  height: 100,
                                )
                                    : FadeInImage(
                                  placeholder: const AssetImage('assets/u_user.png'),
                                  image: NetworkImage(editUserAdmin.avatar),
                                  fit: BoxFit.cover,
                                  width: 100,
                                  height: 100,
                                  imageErrorBuilder: (context, error, stackTrace) {
                                    return Image.asset(
                                      'assets/error_image.png', // Изображение ошибки
                                      fit: BoxFit.cover,
                                      width: 100,
                                      height: 100,
                                    );
                                  },
                                ),
                              ),
                            ),

                            const SizedBox(width: 20,),

                            Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(editUserAdmin.getFullName()),
                                    Text(
                                        '${editUserAdmin.calculateYears()}, ${editUserAdmin.adminRole.getNameOrDescOfRole(true)}',
                                      style: Theme.of(context).textTheme.labelMedium!.copyWith(color: AppColors.greyText),
                                    ),

                                    Row(
                                      children: [
                                        Text(
                                          'В нашей команде ',
                                          style: Theme.of(context).textTheme.labelSmall!.copyWith(color: AppColors.greyText),
                                        ),
                                        Text(
                                          editUserAdmin.calculateExperienceTime(),
                                          style: Theme.of(context).textTheme.labelSmall!.copyWith(color: Colors.green),
                                        ),
                                      ],
                                    ),

                                  ],
                                )
                            ),

                          ],
                        ),

                        if (canEdit) const SizedBox(height: 5,),
                        if (canEdit) GestureDetector(
                          onTap: ()async{
                            await _pickImage();
                          },
                          child: Text(
                            'Изменить фото',
                            style: Theme.of(context).textTheme.labelMedium!.copyWith(color: AppColors.brandColor, decoration: TextDecoration.underline,),
                          ),
                        ),

                        const SizedBox(height: 40,),

                        _buildAdaptiveRow(
                            isMobile,
                            [
                              _buildTextField(
                                  controller: nameController,
                                  labelText: 'Имя',
                                  canEdit: canEdit,
                                  icon: FontAwesomeIcons.idBadge
                              ),
                              _buildTextField(
                                  controller: lastnameController,
                                  labelText: 'Фамилия',
                                  canEdit: canEdit,
                                  icon: FontAwesomeIcons.idBadge
                              )

                        ]
                        ),

                        _buildAdaptiveRow(
                            isMobile,
                            [
                              _buildTextField(
                                  controller: emailController,
                                  labelText: 'Email',
                                  canEdit: false,
                                  icon: FontAwesomeIcons.envelope
                              ),
                              _buildTextField(
                                  controller: phoneController,
                                  labelText: 'Контактный телефон',
                                  canEdit: canEdit,
                                  icon: FontAwesomeIcons.phone
                              )

                            ]
                        ),

                        _buildAdaptiveRow(
                            isMobile,
                            [
                              _buildTextField(
                                  controller: cityController,
                                  labelText: 'Город',
                                  canEdit: canEdit,
                                  icon: FontAwesomeIcons.mapLocation,
                                readOnly: true,
                                onTap: () async {
                                  await showCityTwoPopup();
                                },
                              ),
                              _buildTextField(
                                  controller: birthDateController,
                                  labelText: 'Дата рождения',
                                  canEdit: canEdit,
                                  icon: FontAwesomeIcons.cakeCandles,
                                readOnly: true,
                                onTap: () async {
                                  await _selectDate(context);
                                },
                              )

                            ]
                        ),

                        _buildAdaptiveRow(
                            isMobile,
                            [
                              _buildTextField(
                                controller: adminRoleController,
                                labelText: 'Роль в приложении',
                                canEdit: canEditRole(),
                                icon: FontAwesomeIcons.userGear,
                                readOnly: true,
                                onTap: () async {
                                  await showRolePopup();
                                },
                              ),
                              _buildTextField(
                                controller: adminGenderController,
                                labelText: 'Пол',
                                canEdit: canEdit,
                                icon: FontAwesomeIcons.marsAndVenus,
                                readOnly: true,
                                onTap: () {
                                  genderPopup();
                                },
                              )

                            ]
                        ),

                        if (canEdit) const SizedBox(height: 20,),
                        if (canEdit) Row(
                          children: [
                            Expanded(
                              child: ElementsOfDesign.customButton(
                                method: (){
                                  canEdit = false;
                                  setTextFieldsOnDefault();
                                },
                                textOnButton: 'Отменить',
                                context: context,
                                buttonState: ButtonStateEnum.secondary
                              ),
                            ),
                            const SizedBox(width: 20,),
                            Expanded(
                              child: ElementsOfDesign.customButton(
                                method: ()async{

                                  setState(() {
                                    saving = true;
                                  });

                                  setEditAdminBeforeSaving();

                                  String publishResult = await editUserAdmin.publishToDb(_imageFile);

                                  if (publishResult == SystemConstants.successConst) {
                                    _showSnackBar('Пользователь успешно сохранен!');
                                    await getAdminsInfo(fromDB: false);
                                    canEdit = false;
                                    setTextFieldsOnDefault();
                                  } else {
                                    _showSnackBar(publishResult);
                                  }

                                  setState(() {
                                    saving = false;
                                  });

                                },
                                textOnButton: 'Cохранить',
                                context: context,
                              ),
                            ),
                          ],
                        )
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

  // Метод для адаптивного ряда
  Widget _buildAdaptiveRow(bool isMobile, List<Widget> children) {
    if (isMobile) {
      return Column(
        children: children
            .map((child) => Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: child,
        ))
            .toList(),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Row(
          children: [
            for (int i = 0; i < children.length; i++) ...[
              Expanded(child: children[i]),
              if (i < children.length - 1) const SizedBox(width: 20), // Отступ только между элементами
            ],
          ],
        ),
      );
    }
  }

  // Метод для создания TextField
  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required bool canEdit,
    required IconData icon,
    VoidCallback? onTap,
    bool readOnly = false,
  }) {
    return TextField(
      style: Theme.of(context).textTheme.bodyMedium,
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(icon, size: 18,),
      ),
      enabled: canEdit,
      readOnly: readOnly,
      onTap: onTap,
    );
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
    DateTime initial = editUserAdmin.birthDate;
    if (selectedBirthDateOnEdit.year != 2100) initial = selectedBirthDateOnEdit;

    final DateTime? picked = await showDatePicker(

      locale: const Locale('ru'), // Локализация (например, русский)
      context: context,
      initialDate: initial,
      firstDate: DateTime(1930),
      lastDate: DateTime.now(),
      helpText: 'Выбранная дата',
      cancelText: 'Отмена',
      confirmText: 'Подтвердить',
      keyboardType: TextInputType.datetime,
      initialEntryMode: DatePickerEntryMode.inputOnly,
      fieldLabelText: 'Ваша дата рождения',


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
    await Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
          builder: (context) => const LogInScreen(),
      ),
        (_) => false
    );
  }
}
