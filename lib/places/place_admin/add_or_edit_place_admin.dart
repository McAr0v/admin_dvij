import 'dart:io';
import 'package:admin_dvij/constants/admin_role_constants.dart';
import 'package:admin_dvij/constants/buttons_constants.dart';
import 'package:admin_dvij/constants/system_constants.dart';
import 'package:admin_dvij/design/loading_screen.dart';
import 'package:admin_dvij/design_elements/button_state_enum.dart';
import 'package:admin_dvij/design_elements/elements_of_design.dart';
import 'package:admin_dvij/places/place_admin/place_admin_class.dart';
import 'package:admin_dvij/places/place_admin/place_role_class.dart';
import 'package:admin_dvij/places/place_admin/place_role_picker.dart';
import 'package:admin_dvij/users/admin_user/admin_user_class.dart';
import 'package:admin_dvij/users/simple_users/creator_popup.dart';
import 'package:admin_dvij/users/simple_users/simple_users_list.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../constants/errors_constants.dart';
import '../../design/app_colors.dart';
import '../../system_methods/system_methods_class.dart';
import '../../users/simple_users/simple_user.dart';

/// Если не передать User, будет создание.  Если передать - редактирование
class AddOrEditPlaceAdmin extends StatefulWidget {
  final SimpleUser? user;
  final String placeId;
  const AddOrEditPlaceAdmin({this.user, required this.placeId, Key? key}) : super(key: key);

  @override
  State<AddOrEditPlaceAdmin> createState() => _AddOrEditPlaceAdminState();
}

class _AddOrEditPlaceAdminState extends State<AddOrEditPlaceAdmin> {
  SystemMethodsClass sm = SystemMethodsClass();
  SimpleUsersList usersListClass = SimpleUsersList();

  AdminUserClass currentAdmin = AdminUserClass.empty();
  List<SimpleUser> usersList = [];

  SimpleUser chosenUser = SimpleUser.empty();
  PlaceRole chosenPlaceAdminRole = PlaceRole();

  bool loading = false;
  bool saving = false;

  @override
  void initState() {
    initialization();
    super.initState();
  }

  Future<void> initialization ({bool fromDb = false}) async {

    setState(() {
      loading = true;
    });

    // Если пользователь не задан, то это создание
    if (widget.user == null){
      // Тогда подгружаем список всех пользователей
      usersList = await usersListClass.getDownloadedList(fromDb: fromDb);
      // Выбранный пользователь пустой
      chosenUser = SimpleUser.empty();
      // Выбранная роль - обычный пользователь
      chosenPlaceAdminRole = chosenUser.getPlaceRole(placeId: widget.placeId).placeRole;
    } else {
      // В выбранного пользователя указываем переданного пользователя
      chosenUser = widget.user!;
      // В качестве выбранной роли подгружаем из пользователя
      chosenPlaceAdminRole = widget.user!.getPlaceRole(placeId: widget.placeId).placeRole;
    }

    // Подгружаем текущего админа для отображения надписи "Это вы"
    currentAdmin = await currentAdmin.getCurrentUser(fromDb: fromDb);

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
            widget.user == null ? AdminRoleConstants.addAdmin : '${AdminRoleConstants.editAdmin} ${widget.user!.getFullName()}'
        ),

        leading: IconButton(
          icon: const Icon(FontAwesomeIcons.chevronLeft, size: 18,),
          onPressed: () {
            navigateBackWithResult();
          },
        ),
      ),
      body: Stack(
        children: [
          if (loading) const LoadingScreen()
          else if (saving) const LoadingScreen(loadingText: AdminRoleConstants.savingAdminProcess,)
          else Center(
            child: Column(
              children: [
                Container(
                  width: sm.getScreenWidth(),
                  padding: EdgeInsets.all(Platform.isMacOS || Platform.isWindows ? 30 : 10),
                  child: Column(
                    children: [

                      // Карточка пользователя, если это редактирование или создание на этапе выбранного пользователя
                      if (widget.user != null || chosenUser.uid.isNotEmpty) chosenUser.getPlaceAdminUserCardInList(
                          context: context,
                          // Если создание, то доступна кнопка редактирования, чтобы выбрать пользователя заново
                          // Если редактирование - сменить пользователя нельзя
                          onEdit: widget.user == null ? () async {
                            await choseUser();
                          } : null,
                          onDelete: null,
                          onCardTap: null,
                          currentAdmin: currentAdmin,
                          placeId: widget.placeId
                      ),



                      // Виджет "Пользователь не выбран". Первое что видно при создании
                      if (widget.user == null && chosenUser.uid.isEmpty) Card(
                        color: AppColors.greyOnBackground,
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: ElementsOfDesign.buildAdaptiveRow(
                              isMobile: isMobile,
                              bottomPadding: 0,
                              children: [


                                Text(
                                  ErrorConstants.noChosenUser,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),

                                if (isMobile) const SizedBox(height: 20,),

                                ElementsOfDesign.customButton(
                                    method: () async {
                                      await choseUser();
                                    },
                                    textOnButton: ButtonsConstants.chooseUser,
                                    context: context,
                                    buttonState: ButtonStateEnum.secondary
                                )
                              ]
                          ),
                        ),
                      ),

                      const SizedBox(height: 10,),

                      // Виджет выбора роли
                      // Доступен, если пользователя выбрали и пользователь не является создаталем
                      if (chosenUser.uid.isNotEmpty && chosenPlaceAdminRole.role != PlaceUserRoleEnum.creator) Card(
                        color: AppColors.greyOnBackground,
                        child: Padding(
                            padding: const EdgeInsets.all(20),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                        chosenPlaceAdminRole.toString(needTranslate: true),
                                      style: Theme.of(context).textTheme.titleMedium,
                                    ),
                                    Text(
                                        chosenPlaceAdminRole.getDesc(),
                                      style: Theme.of(context).textTheme.labelMedium,
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(width: 20,),

                              IconButton(
                                  onPressed: () async {
                                    await choseRole();
                                  },
                                  icon: const Icon(FontAwesomeIcons.gear, size: 15,)
                              ),

                            ],
                          )
                        ),
                      ),

                      // Виджет - предупреждение, что пользователь создатель. Его нельзя менять

                      if (chosenPlaceAdminRole.role == PlaceUserRoleEnum.creator) Card(
                        color: AppColors.greyOnBackground,
                        child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Row(
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      AdminRoleConstants.thisIsCreator,
                                      style: Theme.of(context).textTheme.titleMedium,
                                    ),
                                    const SizedBox(height: 5,),
                                    Text(
                                      AdminRoleConstants.cantChangeCreator,
                                      style: Theme.of(context).textTheme.labelMedium,
                                    ),
                                  ],
                                ),
                              ],
                            )
                        ),
                      ),

                      const SizedBox(height: 20,),

                      // Кнопки "Сохранить" и "Отменить".
                      // Доступны если выбрали пользователя и он не создатель
                      if (chosenPlaceAdminRole.role != PlaceUserRoleEnum.creator && chosenUser.uid.isNotEmpty) Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: ElementsOfDesign.customButton(
                                method: () async {
                                  await initialization();
                                },
                                textOnButton: ButtonsConstants.cancel,
                                context: context,
                                buttonState: ButtonStateEnum.secondary
                            ),
                          ),

                          const SizedBox(width: 20,),

                          Expanded(
                            flex: 1,
                            child: ElementsOfDesign.customButton(
                                method: () async {
                                  await saveAdmin();
                                },
                                textOnButton: ButtonsConstants.save,
                                context: context,
                            ),
                          ),
                        ],
                      ),
                    ]
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Future<void> saveAdmin() async {

    // Сохранение доступно, если пользователь выбран
    if (chosenUser.uid.isNotEmpty){

      setState(() {
        saving = true;
      });

      // Заполняем переменную администратора заведения
      PlaceAdmin admin = PlaceAdmin(
          placeRole: chosenPlaceAdminRole,
          placeId: widget.placeId
      );

      String result = '';

      // Если пользователю задали админскую роль, публикуем запись
      if (chosenPlaceAdminRole.role != PlaceUserRoleEnum.reader){
        result = await chosenUser.publishPlaceRoleForCurrentUser(admin);
      } else {
        // Если задали обычного пользователя, удаляем имеющуюся запись
        result = await chosenUser.deletePlaceRoleFromUser(widget.placeId);
      }

      // Если результат успешный. возвращаемся на предыдущий экран
      if (result == SystemConstants.successConst){
        navigateBackWithResult();
      }

      setState(() {
        saving = false;
      });

    }
  }

  Future<void> choseRole() async {
    final result = await sm.getPopup(context: context, page: const PlaceRolePicker());
    if (result != null){
      setState(() {
        chosenPlaceAdminRole = result;
      });
    }
  }

  Future<void> choseUser() async {
    final result = await sm.getPopup(context: context, page: CreatorPopup(placeId: widget.placeId,));

    if (result != null) {
      setState(() {
        chosenUser = result;
        chosenPlaceAdminRole = chosenUser
            .getPlaceRole(placeId: widget.placeId)
            .placeRole;
      });
    }
  }

  void navigateBackWithResult() {
    sm.popBackToPreviousPageWithResult(context: context, result: true);
  }
}
