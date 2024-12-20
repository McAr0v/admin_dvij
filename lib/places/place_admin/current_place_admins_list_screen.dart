import 'package:admin_dvij/constants/admin_role_constants.dart';
import 'package:admin_dvij/constants/buttons_constants.dart';
import 'package:admin_dvij/design/app_colors.dart';
import 'package:admin_dvij/design_elements/elements_of_design.dart';
import 'package:admin_dvij/places/place_admin/add_or_edit_place_admin.dart';
import 'package:admin_dvij/places/place_admin/place_role_class.dart';
import 'package:admin_dvij/places/place_class.dart';
import 'package:admin_dvij/users/admin_user/admin_user_class.dart';
import 'package:admin_dvij/users/simple_users/simple_user.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../constants/system_constants.dart';
import '../../design/loading_screen.dart';
import '../../system_methods/system_methods_class.dart';
import '../../users/simple_users/simple_users_list.dart';


class CurrentPlaceAdminsListScreen extends StatefulWidget {
  final Place place;
  const CurrentPlaceAdminsListScreen({required this.place, Key? key}) : super(key: key);

  @override
  State<CurrentPlaceAdminsListScreen> createState() => _CurrentPlaceAdminsListScreenState();
}

class _CurrentPlaceAdminsListScreenState extends State<CurrentPlaceAdminsListScreen> {

  SimpleUsersList usersList = SimpleUsersList();
  SystemMethodsClass sm = SystemMethodsClass();

  AdminUserClass currentAdmin = AdminUserClass.empty();

  List<SimpleUser> adminsList = [];
  bool loading = false;
  bool deleting = false;

  @override
  void initState() {
    initialization();
    super.initState();
  }

  Future<void> initialization({bool fromDb = false}) async {

    setState(() {
      loading = true;
    });

    // Подгруажем список пользователей-админов для нашего заведения
    adminsList = await usersList.getAdminsFromPlace(placeId: widget.place.id, fromDb: fromDb);

    // Подгружаем текущего админа всего приложения
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
            '${AdminRoleConstants.adminsInChosenPlace} "${widget.place.name}"'
        ),

        leading: IconButton(
          icon: const Icon(FontAwesomeIcons.chevronLeft, size: 18,),
          onPressed: () {
            navigateBackWithResult();
          },
        ),

        actions: [

          // Иконка обновления данных.

          IconButton(
            onPressed: () async {
              await initialization(fromDb: true);
            },
            icon: const Icon(FontAwesomeIcons.arrowsRotate, size: 15, color: AppColors.white,),
          ),

          // Иконка добавления пользователя

          IconButton(
            onPressed: () async {
              await addOrEditAdmin(user: null);
            },
            icon: const Icon(FontAwesomeIcons.plus, size: 15, color: AppColors.white,),
          ),

        ],
      ),

      body: Stack(
        children: [
          if (loading) const LoadingScreen(loadingText: AdminRoleConstants.loadingAdminProcess)

          else if (deleting) const LoadingScreen(loadingText: AdminRoleConstants.deletingAdminProcess)

          else Column(
            children: [

              if (adminsList.isEmpty) const Expanded(
                  child: Center(
                    child: Text(SystemConstants.emptyList),
                  )
              ),

              if (adminsList.isNotEmpty) Expanded(

                  child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(10, 10, 10, 30),
                      itemCount: adminsList.length,
                      itemBuilder: (context, index) {

                        return adminsList[index].getPlaceAdminUserCardInList(
                            context: context,
                            // Кнопка редактирования доступна только если пользователь не создатель
                            onEdit: adminsList[index].getPlaceRole(placeId: widget.place.id).placeRole.role == PlaceUserRoleEnum.creator
                                ? null
                                : () async {
                              await addOrEditAdmin(user: adminsList[index]);
                            },
                            onCardTap: null,
                            // Кнопка удаления доступна только если пользователь не создатель
                            onDelete: adminsList[index].getPlaceRole(placeId: widget.place.id).placeRole.role == PlaceUserRoleEnum.creator
                                ? null
                                : () async {
                              await deleteAdmin(user: adminsList[index]);
                            },
                            currentAdmin: currentAdmin,
                          placeId: widget.place.id
                        );
                      }
                  )
              )
            ],
          )
        ],
      ),

    );
  }

  Future<void> deleteAdmin({required SimpleUser user}) async {

    setState(() {
      deleting = true;
    });

    bool? confirm = await ElementsOfDesign.exitDialog(
        context,
        AdminRoleConstants.deleteAdminDesc,
        ButtonsConstants.delete,
        ButtonsConstants.cancel,
        AdminRoleConstants.deleteAdminHeadline
    );

    if (confirm != null && confirm) {
      String result = await user.deletePlaceRoleFromUser(widget.place.id);

      await initialization();

      if (result == SystemConstants.successConst){
        _showSnackBar(AdminRoleConstants.deleteAdminSuccess);
      }
    }

    setState(() {
      deleting = false;
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

  Future<void> addOrEditAdmin({SimpleUser? user}) async {
    final results = await sm.pushToPageWithResult(context: context, page: AddOrEditPlaceAdmin(user: user, placeId: widget.place.id,));

    if (results != null){
      await initialization();
    }
  }

  void navigateBackWithResult() {
    sm.popBackToPreviousPageWithResult(context: context, result: true);
  }

}
