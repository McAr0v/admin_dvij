import 'dart:io';

import 'package:admin_dvij/auth/log_in_screen.dart';
import 'package:admin_dvij/cities/cities_list_class.dart';
import 'package:admin_dvij/constants/admins_constants.dart';
import 'package:admin_dvij/constants/screen_constants.dart';
import 'package:admin_dvij/design/loading_screen.dart';
import 'package:admin_dvij/design_elements/button_state_enum.dart';
import 'package:admin_dvij/navigation/drawer_custom.dart';
import 'package:admin_dvij/system_methods/system_methods_class.dart';
import 'package:admin_dvij/users/roles/admins_roles_class.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../cities/city_class.dart';
import '../cities/city_picker_page.dart';
import '../constants/buttons_constants.dart';
import '../constants/system_constants.dart';
import '../design/app_colors.dart';
import '../design_elements/elements_of_design.dart';
import '../users/admin_user/admin_user_class.dart';
import '../users/genders/gender_class.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  AdminUserClass currentUserAdmin = AdminUserClass.empty();
  SystemMethodsClass systemMethods = SystemMethodsClass();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController lastnameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController birthDateController = TextEditingController();
  final TextEditingController adminRoleController = TextEditingController();
  final TextEditingController adminGenderController = TextEditingController();

  City chosenCityOnEdit = City.empty();
  DateTime selectedBirthDateOnEdit = DateTime(2100);
  AdminRoleClass chosenAdminRole = AdminRoleClass(AdminRole.viewer);
  Gender chosenAdminGender = Gender();

  bool loading = false;
  bool logOuting = false;
  bool saving = false;

  bool canEdit = false;

  @override
  void initState() {

    getAdmin();

    super.initState();
  }

  void setTextFieldsOnDefault(){
    setState(() {
      emailController.text = currentUserAdmin.email;
      nameController.text = currentUserAdmin.name;
      lastnameController.text = currentUserAdmin.lastName;
      phoneController.text = currentUserAdmin.phone;
      cityController.text = currentUserAdmin.city.name;
      birthDateController.text = currentUserAdmin.formatBirthDateTime();
      adminRoleController.text = currentUserAdmin.adminRole.getNameOrDescOfRole(true);
      //adminGenderController.text =
      chosenCityOnEdit = City.empty();
      selectedBirthDateOnEdit = DateTime(2100);
      chosenAdminRole = AdminRoleClass(AdminRole.viewer);
      chosenAdminGender = Gender();
    });
  }

  Future<void> getAdmin({bool fromDB = false}) async{
    setState(() {

      loading = true;

    });

    currentUserAdmin = await currentUserAdmin.getCurrentUser(fromDb: fromDB);

    setTextFieldsOnDefault();


    setState(() {

      loading = false;

    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(ScreenConstants.profilePage),
        actions: [

          IconButton(
            onPressed: () async {
              await getAdmin(fromDB: true);
            },
            icon: const Icon(FontAwesomeIcons.arrowsRotate, size: 15, color: AppColors.white,),
          ),
          IconButton(
            onPressed: () async {

              setState(() {
                canEdit = true;
              });

            },
            icon: const Icon(FontAwesomeIcons.penToSquare, size: 15, color: AppColors.white,),
          ),
          IconButton(
            onPressed: () async {
              _singOut();
            },
            icon: const Icon(FontAwesomeIcons.arrowRightFromBracket, size: 15, color: AppColors.white,),
          ),

        ],
      ),
      body: Stack(
        children: [
          if (loading) const LoadingScreen(loadingText: SystemConstants.loadingDefault),
          if (logOuting) const LoadingScreen(loadingText: 'Выход из аккаунта'),
          if (saving) const LoadingScreen(loadingText: 'Сохранение изменений'),
          if (!loading) SingleChildScrollView(
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

                            if (currentUserAdmin.avatar.isNotEmpty) CircleAvatar(
                              radius: 40,
                              backgroundColor: Colors.grey, // Цвет фона, который будет виден во время загрузки
                              child: ClipOval(
                                child: FadeInImage(
                                  placeholder: const AssetImage('assets/u_user.png'),
                                  image: NetworkImage(currentUserAdmin.avatar),
                                  fit: BoxFit.cover,
                                  width: 100,
                                  height: 100,
                                  imageErrorBuilder: (context, error, stackTrace) {
                                    return Image.asset('assets/error_image.png'); // Изображение ошибки, если загрузка не удалась
                                  },
                                ),
                              ),
                            ),

                            const SizedBox(width: 20,),

                            Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(currentUserAdmin.getFullName()),
                                    Text(
                                        '${currentUserAdmin.calculateYears()}, ${currentUserAdmin.adminRole.getNameOrDescOfRole(true)}',
                                      style: Theme.of(context).textTheme.labelMedium!.copyWith(color: AppColors.greyText),
                                    ),

                                    Row(
                                      children: [
                                        Text(
                                          'В нашей команде ',
                                          style: Theme.of(context).textTheme.labelSmall!.copyWith(color: AppColors.greyText),
                                        ),
                                        Text(
                                          currentUserAdmin.calculateExpirienseTime(),
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
                          child: Text(
                            'Изменить фото',
                            style: Theme.of(context).textTheme.labelMedium!.copyWith(color: AppColors.brandColor, decoration: TextDecoration.underline,),
                          ),
                        ),

                        const SizedBox(height: 40,),

                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                style: Theme.of(context).textTheme.bodyMedium,
                                controller: nameController,
                                decoration: const InputDecoration(
                                  labelText: 'Имя',
                                  prefixIcon: Icon(Icons.email),
                                ),
                                enabled: canEdit,
                              ),
                            ),

                            const SizedBox(width: 20,),

                            Expanded(
                              child: TextField(
                                style: Theme.of(context).textTheme.bodyMedium,
                                controller: lastnameController,
                                decoration: const InputDecoration(
                                  labelText: 'Фамилия',
                                  prefixIcon: Icon(Icons.email),
                                ),
                                enabled: canEdit,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20,),

                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                style: Theme.of(context).textTheme.bodyMedium,
                                controller: emailController,
                                decoration: const InputDecoration(
                                  labelText: 'Email',
                                  prefixIcon: Icon(Icons.email),
                                ),
                                enabled: false,
                              ),
                            ),

                            const SizedBox(width: 20,),

                            Expanded(
                              child: TextField(
                                style: Theme.of(context).textTheme.bodyMedium,
                                controller: phoneController,
                                decoration: const InputDecoration(
                                  labelText: 'Контактный телефон',
                                  prefixIcon: Icon(Icons.email),
                                ),
                                enabled: canEdit,
                              ),
                            ),

                          ],
                        ),

                        const SizedBox(height: 20,),

                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                style: Theme.of(context).textTheme.bodyMedium,
                                controller: cityController,
                                decoration: const InputDecoration(
                                  labelText: 'Город',
                                  prefixIcon: Icon(Icons.email),
                                ),
                                enabled: canEdit,
                                onTap: () async {
                                  await _showCityPickerDialog();
                                },
                                readOnly: true
                              ),
                            ),

                            const SizedBox(width: 20,),

                            Expanded(
                              child: TextField(
                                style: Theme.of(context).textTheme.bodyMedium,
                                controller: birthDateController,
                                decoration: const InputDecoration(
                                  labelText: 'Дата рождения',
                                  prefixIcon: Icon(Icons.email),
                                ),
                                enabled: canEdit,
                                readOnly: true,
                                onTap: () async {
                                  //await _showDatePickerDialog();
                                  await _selectDate(context);
                                },
                              ),
                            ),

                          ],
                        ),

                        const SizedBox(height: 20,),

                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                  style: Theme.of(context).textTheme.bodyMedium,
                                  controller: adminRoleController,
                                  decoration: const InputDecoration(
                                    labelText: 'Роль в приложении',
                                    prefixIcon: Icon(Icons.email),
                                  ),
                                  enabled: canEdit && (currentUserAdmin.adminRole.adminRole == AdminRole.creator || currentUserAdmin.adminRole.adminRole ==  AdminRole.superAdmin),
                                  onTap: () async {
                                    //await _showCityPickerDialog();
                                  },
                                  readOnly: true
                              ),
                            ),

                            const SizedBox(width: 20,),

                            Expanded(
                              child: TextField(
                                style: Theme.of(context).textTheme.bodyMedium,
                                controller: birthDateController,
                                decoration: const InputDecoration(
                                  labelText: 'Пол',
                                  prefixIcon: Icon(Icons.email),
                                ),
                                enabled: canEdit,
                                readOnly: true,
                                onTap: () async {
                                  //await _showDatePickerDialog();
                                  //await _selectDate(context);
                                },
                              ),
                            ),

                          ],
                        ),

                        if (canEdit) const SizedBox(height: 40,),
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
                                method: (){},
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

  Future<void> _showCityPickerDialog() async {

    dynamic returnedCity = await systemMethods.showPopUpDialog(
        context: context,
        page: const CityPickerPage()
    );

    if (returnedCity != null) {

      setState(() {
        chosenCityOnEdit = returnedCity;
        cityController.text = chosenCityOnEdit.name;
      });

    }
  }

  /*Future<void> _showDatePickerDialog() async {

    dynamic returnedCity = await systemMethods.showPopUpDialog(
        context: context,
        page: DataPickerCustom(
            onActionPressed: () async{
              await _selectDate(context, needClearInitialDate: true);
            },
            labelText: 'Выбери дату рождения'
        )
    );

    if (returnedCity != null) {

      setState(() {
        chosenCityOnEdit = returnedCity;
        cityController.text = chosenCityOnEdit.name;
      });

    }
  }*/

  Future<void> _selectDate(BuildContext context, {bool needClearInitialDate = false}) async {
    DateTime initial = currentUserAdmin.birthDate;
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

    if (picked != null && picked != currentUserAdmin.birthDate) {
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
