import 'package:admin_dvij/design/loading_screen.dart';
import 'package:admin_dvij/design_elements/button_state_enum.dart';
import 'package:admin_dvij/design_elements/elements_of_design.dart';
import 'package:admin_dvij/places/place_admin/place_admin_class.dart';
import 'package:admin_dvij/places/place_admin/place_role_class.dart';
import 'package:admin_dvij/users/admin_user/admin_user_class.dart';
import 'package:admin_dvij/users/simple_users/simple_users_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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

  List<PlaceRole> placesRoles = [];
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
    } else {
      chosenUser = widget.user!;
      chosenPlaceAdminRole = widget.user!.getPlaceRole(placeId: widget.placeId).placeRole;
    }

    currentAdmin = await currentAdmin.getCurrentUser(fromDb: fromDb);

    placesRoles = chosenPlaceAdminRole.getPlacesRolesList();

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
          else Column(
            children: [
              if (widget.user != null) widget.user!.getPlaceAdminUserCardInList(
                  context: context,
                  onTap: (){},
                  currentAdmin: currentAdmin,
                  placeId: widget.placeId
              ),

              Text('Текущая роль'),
              ElementsOfDesign.customButton(
                  method: (){},
                  textOnButton: chosenPlaceAdminRole.toString(needTranslate: true),
                  context: context,
                buttonState: ButtonStateEnum.secondary
              ),

              Card(
                child: Padding(
                    padding: EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Text(chosenPlaceAdminRole.toString(needTranslate: true)),
                      Text(chosenPlaceAdminRole.getDesc()),
                    ],
                  ),
                ),
              )

            ],
          )
        ],
      ),
    );
  }

  void navigateBackWithResult() {
    sm.popBackToPreviousPageWithResult(context: context, result: true);
  }
}
