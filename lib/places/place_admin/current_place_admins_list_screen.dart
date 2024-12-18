import 'package:admin_dvij/design/app_colors.dart';
import 'package:admin_dvij/places/place_admin/add_or_edit_place_admin.dart';
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

  @override
  void initState() {
    initialization();
    super.initState();
  }

  Future<void> initialization({bool fromDb = false}) async {

    setState(() {
      loading = true;
    });

    adminsList = await usersList.getAdminsFromPlace(placeId: widget.place.id, fromDb: fromDb);

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
            'Администраторы в "${widget.place.name}"'
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
          if (loading) const LoadingScreen(loadingText: 'Загрузка админов'),
          if (!loading) Column(
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
                            onTap: () async {
                              await addOrEditAdmin(user: adminsList[index]);
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
