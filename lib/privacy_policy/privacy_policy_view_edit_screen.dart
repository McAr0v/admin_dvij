import 'dart:io';
import 'package:admin_dvij/constants/system_constants.dart';
import 'package:admin_dvij/design_elements/button_state_enum.dart';
import 'package:admin_dvij/privacy_policy/privacy_enum.dart';
import 'package:admin_dvij/privacy_policy/privacy_policy_class.dart';
import 'package:admin_dvij/privacy_policy/privacy_policy_list_screen.dart';
import 'package:admin_dvij/privacy_policy/privacy_status_picker.dart';
import 'package:admin_dvij/system_methods/dates_methods.dart';
import 'package:admin_dvij/system_methods/system_methods_class.dart';
import 'package:admin_dvij/users/admin_user/admin_user_class.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../constants/buttons_constants.dart';
import '../design/app_colors.dart';
import '../design/loading_screen.dart';
import '../design_elements/elements_of_design.dart';

class PrivacyPolicyViewEditScreen extends StatefulWidget {

  final PrivacyPolicyClass? copiedPolicy;
  final bool canEdit;
  final bool isNew;

  const PrivacyPolicyViewEditScreen({this.copiedPolicy, required this.canEdit, required this.isNew, super.key});

  @override
  State<PrivacyPolicyViewEditScreen> createState() => _PrivacyPolicyViewEditScreenState();
}

class _PrivacyPolicyViewEditScreenState extends State<PrivacyPolicyViewEditScreen> {
  SystemMethodsClass sm = SystemMethodsClass();
  DateMethods dm = DateMethods();

  AdminUserClass currentAdmin = AdminUserClass.empty();

  bool saving = false;
  bool loading = false;
  bool canEdit = false;

  TextEditingController startTextController = TextEditingController();
  TextEditingController dataCollectionController = TextEditingController();
  TextEditingController dataUsageController = TextEditingController();
  TextEditingController transferDataController = TextEditingController();
  TextEditingController dataSecurityController = TextEditingController();
  TextEditingController yourRightsController = TextEditingController();
  TextEditingController changesController = TextEditingController();
  TextEditingController contactsController = TextEditingController();

  PrivacyPolicyClass privacy = PrivacyPolicyClass.empty();

  PrivacyStatus chosenStatus = PrivacyStatus();

  Future <void> initialization() async {
    setState(() {
      loading = true;
    });

    currentAdmin = await currentAdmin.getCurrentUser(fromDb: false);

    if (widget.copiedPolicy != null && widget.canEdit && !widget.isNew) {
      privacy = PrivacyPolicyClass.fillPrivacy(copiedEntity: widget.copiedPolicy!);
    } else if (widget.copiedPolicy != null && widget.canEdit && widget.isNew) {
      privacy = PrivacyPolicyClass.copyPrivacy(copiedEntity: widget.copiedPolicy!);
    } else if (widget.copiedPolicy != null && !widget.canEdit){
      privacy = widget.copiedPolicy!;
    }

    if (widget.copiedPolicy == null || widget.isNew) {
      canEdit = true;
    }

    chosenStatus = privacy.status;



    startTextController.text = privacy.startText;
    dataCollectionController.text = privacy.dataCollection;
    dataUsageController.text = privacy.dataUsage;
    transferDataController.text = privacy.transferData;
    dataSecurityController.text = privacy.dataSecurity;
    yourRightsController.text = privacy.yourRights;
    changesController.text = privacy.changes;
    contactsController.text = privacy.contacts;

    setState(() {
      loading = false;
    });
  }

  @override
  void initState() {

    initialization();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // Ограничение ширины на настольных платформах
    bool isDesktop = Platform.isWindows || Platform.isMacOS || Platform.isLinux;
    double maxWidth = isDesktop ? 600 : double.infinity;

    return Scaffold(
      appBar: AppBar(
        title: Text('Политика от ${privacy.getFolderId()}',),

        // Задаем особый выход на кнопку назад
        // Чтобы не плодились экраны назад с разным списком сущностей

        leading: IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: navigateToPrivacyListScreen,
        ),

        actions: [

          // Иконка редактирования. Доступна если у текущего админа есть доступ или это не создание заведения

          if (currentAdmin.adminRole.accessToEditPrivacyPolicy() && widget.canEdit && widget.copiedPolicy != null) IconButton(
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
          if (saving) const LoadingScreen(loadingText: 'Сохранение политики конфиденциальности')
          else if (loading) const LoadingScreen()
          else Container(
            alignment: Alignment.topCenter,
            child: SizedBox(
              width: maxWidth,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [

                      ElementsOfDesign.buildAdaptiveRow(
                          isMobile: !isDesktop,
                          children: [
                            ElementsOfDesign.buildTextFieldWithoutController(
                                controllerText: sm.formatDateTimeToHumanView(privacy.date),
                                labelText: 'Дата публикации',
                                canEdit: false,
                                icon: FontAwesomeIcons.calendarDay,
                                context: context
                            ),

                            ElementsOfDesign.buildTextFieldWithoutController(
                                controllerText: chosenStatus.toString(translate: true),
                                labelText: 'Статус',
                                canEdit: canEdit,
                                icon: FontAwesomeIcons.calendarDay,
                                context: context,
                                onTap: () async {
                                  await chooseStatus();
                              },
                              readOnly: true
                            ),
                          ]
                      ),

                      ElementsOfDesign.buildTextField(
                          controller: startTextController,
                          labelText: 'Стартовый текст',
                          canEdit: canEdit,
                          icon: Icons.place,
                          context: context,
                        maxLines: null,
                      ),

                      const SizedBox(height: 20,),

                      ElementsOfDesign.buildTextField(
                        controller: dataCollectionController,
                        labelText: 'dataCollectionController',
                        canEdit: canEdit,
                        icon: Icons.place,
                        context: context,
                        maxLines: null,
                      ),

                      const SizedBox(height: 20,),

                      ElementsOfDesign.buildTextField(
                        controller: dataUsageController,
                        labelText: 'dataUsageController',
                        canEdit: canEdit,
                        icon: Icons.place,
                        context: context,
                        maxLines: null,
                      ),

                      const SizedBox(height: 20,),

                      ElementsOfDesign.buildTextField(
                        controller: transferDataController,
                        labelText: 'transferDataController',
                        canEdit: canEdit,
                        icon: Icons.place,
                        context: context,
                        maxLines: null,
                      ),

                      const SizedBox(height: 20,),

                      ElementsOfDesign.buildTextField(
                        controller: dataSecurityController,
                        labelText: 'dataSecurityController',
                        canEdit: canEdit,
                        icon: Icons.place,
                        context: context,
                        maxLines: null,
                      ),

                      const SizedBox(height: 20,),

                      ElementsOfDesign.buildTextField(
                        controller: yourRightsController,
                        labelText: 'yourRightsController',
                        canEdit: canEdit,
                        icon: Icons.place,
                        context: context,
                        maxLines: null,
                      ),

                      const SizedBox(height: 20,),

                      ElementsOfDesign.buildTextField(
                        controller: changesController,
                        labelText: 'changesController',
                        canEdit: canEdit,
                        icon: Icons.place,
                        context: context,
                        maxLines: null,
                      ),

                      const SizedBox(height: 20,),

                      ElementsOfDesign.buildTextField(
                        controller: contactsController,
                        labelText: 'contactsController',
                        canEdit: canEdit,
                        icon: Icons.place,
                        context: context,
                        maxLines: null,
                      ),

                      const SizedBox(height: 20.0),

                      if (canEdit) ElementsOfDesign.buildAdaptiveRow(
                          isMobile: !isDesktop,
                          children: [
                            ElementsOfDesign.customButton(
                                method: () async {

                                  PrivacyPolicyClass publishedPolicy = PrivacyPolicyClass(
                                      id: privacy.id,
                                      date: privacy.date,
                                      startText: startTextController.text,
                                      dataCollection: dataCollectionController.text,
                                      dataUsage: dataUsageController.text,
                                      transferData: transferDataController.text,
                                      dataSecurity: dataSecurityController.text,
                                      yourRights: yourRightsController.text,
                                      changes: changesController.text,
                                      contacts: contactsController.text,
                                      status: chosenStatus
                                  );

                                  if (publishedPolicy.checkEmptyFieldsInPrivacy() == SystemConstants.successConst) {
                                    // Если все поля заполнены и можно публиковать
                                    setState(() {
                                      saving = true;
                                    });

                                    String result = await publishedPolicy.publishToDb(null);

                                    if (result == SystemConstants.successConst) {
                                      goBackWithResult();

                                    } else {
                                      _showSnackBar(result);
                                    }

                                    setState(() {
                                      saving = false;
                                    });

                                  } else {
                                    // Если не успешно, выводим причину
                                    _showSnackBar(publishedPolicy.checkEmptyFieldsInPrivacy());
                                  }
                                },
                                textOnButton: ButtonsConstants.save,
                                context: context
                            ),

                            ElementsOfDesign.customButton(
                                method: () async {
                                  setState(() {
                                    canEdit = false;
                                  });
                                  await initialization();
                                },
                                textOnButton: ButtonsConstants.cancel,
                                context: context,
                                buttonState: ButtonStateEnum.secondary
                            )
                          ]
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> chooseStatus() async{
    final results = await sm.getPopup(context: context, page: const PrivacyStatusPicker());
    if (results != null){
      setState(() {
        chosenStatus = results;
      });
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

  void goBackWithResult() {
     sm.popBackToPreviousPageWithResult(context: context, result: true);
  }

  void navigateToPrivacyListScreen() {
    // Метод возвращения на экран списка без результата
    sm.pushAndDeletePreviousPages(context: context, page: const PrivacyPolicyListScreen());
  }
}
