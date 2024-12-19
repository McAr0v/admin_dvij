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
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../design/app_colors.dart';
import '../../system_methods/system_methods_class.dart';
import '../../users/simple_users/simple_user.dart';

class AddOrEditPlaceAdmin extends StatefulWidget {
  final SimpleUser? user;
  final String placeId;
  const AddOrEditPlaceAdmin({this.user, required this.placeId, Key? key}) : super(key: key);

  @override
  State<AddOrEditPlaceAdmin> createState() => _AddOrEditPlaceAdminState();
}

class _AddOrEditPlaceAdminState extends State<AddOrEditPlaceAdmin> {
  SystemMethodsClass sm = SystemMethodsClass();

  AdminUserClass currentAdmin = AdminUserClass.empty();

  SimpleUsersList usersListClass = SimpleUsersList();
  List<SimpleUser> usersList = [];

  SimpleUser chosenUser = SimpleUser.empty();
  PlaceRole chosenPlaceAdminRole = PlaceRole();

  bool loading = false;

  @override
  void initState() {
    initialization();
    super.initState();
  }

  Future<void> initialization ({bool fromDb = false}) async {

    setState(() {
      loading = true;
    });

    if (widget.user == null){
      usersList = await usersListClass.getDownloadedList(fromDb: fromDb);
      chosenUser = SimpleUser.empty();
      chosenPlaceAdminRole = chosenUser.getPlaceRole(placeId: widget.placeId).placeRole;
    } else {
      chosenUser = widget.user!;
      chosenPlaceAdminRole = widget.user!.getPlaceRole(placeId: widget.placeId).placeRole;
    }

    currentAdmin = await currentAdmin.getCurrentUser(fromDb: fromDb);

    setState(() {
      loading = false;
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            widget.user == null ? 'Добавление админа' : 'Редактирование ${widget.user!.getFullName()}'
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
          if (loading) LoadingScreen()
          else Center(
            child: Column(
              children: [
                Container(
                  width: sm.getScreenWidth(),
                  padding: const EdgeInsets.all(30),
                  child: Column(
                    children: [
                      if (widget.user != null || chosenUser.uid.isNotEmpty) chosenUser.getPlaceAdminUserCardInList(
                          context: context,
                          onTap: widget.user == null ? () async {

                            await choseUser();

                          } : null,
                          currentAdmin: currentAdmin,
                          placeId: widget.placeId
                      ),

                      if (widget.user == null && chosenUser.uid.isEmpty) Card(
                        color: AppColors.greyOnBackground,
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Row(
                            children: [
                              const Expanded(
                                  child: Text('Пользователь не выбран'),
                                  flex: 1,
                              ),
                              const SizedBox(height: 20,),
                              Expanded(
                                flex: 1,
                                child: ElementsOfDesign.customButton(
                                    method: () async {
                                      await choseUser();
                                    },
                                    textOnButton: 'Выбрать пользователя',
                                    context: context,
                                    buttonState: ButtonStateEnum.secondary
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 10,),

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
                              SizedBox(width: 20,),

                              IconButton(
                                  onPressed: () async {
                                    await choseRole();
                                  },
                                  icon: Icon(FontAwesomeIcons.gear, size: 15,)
                              ),

                            ],
                          )
                        ),
                      ),

                      if (chosenPlaceAdminRole.role == PlaceUserRoleEnum.creator) Card(
                        color: AppColors.greyOnBackground,
                        child: Padding(
                            padding: EdgeInsets.all(20),
                            child: Row(
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Это создатель',
                                      style: Theme.of(context).textTheme.titleMedium,
                                    ),
                                    Text(
                                      'Его нельзя изменить',
                                      style: Theme.of(context).textTheme.labelMedium,
                                    ),
                                  ],
                                ),
                              ],
                            )
                        ),
                      ),

                      const SizedBox(height: 20,),

                      if (chosenPlaceAdminRole.role != PlaceUserRoleEnum.creator && chosenUser.uid.isNotEmpty) Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: ElementsOfDesign.customButton(
                                method: () async {
                                  await initialization();
                                },
                                textOnButton: 'Отменить',
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
                                textOnButton: 'Сохранить',
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
    if (chosenUser.uid.isNotEmpty){

      PlaceAdmin admin = PlaceAdmin(
          placeRole: chosenPlaceAdminRole,
          placeId: widget.placeId
      );

      String result = await chosenUser.publishPlaceRoleForCurrentUser(admin);


      if (result == SystemConstants.successConst){
        navigateBackWithResult();
      }

    }
  }

  Future<void> choseRole() async {
    final result = await sm.getPopup(context: context, page: PlaceRolePicker());
    if (result != null){
      setState(() {
        chosenPlaceAdminRole = result;
      });

    }
  }

  Future<void> choseUser() async {
    final result = await sm.getPopup(context: context, page: const CreatorPopup());

    if (result != null){
      setState(() {
        chosenUser = result;
        chosenPlaceAdminRole = chosenUser.getPlaceRole(placeId: widget.placeId).placeRole;
      });
    }


  }

  void navigateBackWithResult() {
    sm.popBackToPreviousPageWithResult(context: context, result: true);
  }
}
