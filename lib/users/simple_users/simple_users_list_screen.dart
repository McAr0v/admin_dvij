import 'package:admin_dvij/constants/simple_users_constants.dart';
import 'package:admin_dvij/design_elements/elements_of_design.dart';
import 'package:admin_dvij/system_methods/system_methods_class.dart';
import 'package:admin_dvij/users/simple_users/simple_user.dart';
import 'package:admin_dvij/users/simple_users/simple_user_screen.dart';
import 'package:admin_dvij/users/simple_users/simple_users_list.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../constants/screen_constants.dart';
import '../../constants/system_constants.dart';
import '../../design/app_colors.dart';
import '../../design/loading_screen.dart';
import '../../navigation/drawer_custom.dart';
import '../admin_user/admin_user_class.dart';
import '../admin_user/profile_screen.dart';

class SimpleUsersListScreen extends StatefulWidget {
  const SimpleUsersListScreen({Key? key}) : super(key: key);

  @override
  State<SimpleUsersListScreen> createState() => _SimpleUsersListScreenState();
}

class _SimpleUsersListScreenState extends State<SimpleUsersListScreen> {

  SimpleUsersList usersListClass = SimpleUsersList();
  List<SimpleUser> usersList = [];

  AdminUserClass currentAdmin = AdminUserClass.empty();

  SystemMethodsClass systemMethods = SystemMethodsClass();

  bool loading = false;
  bool upSorting = false;

  final TextEditingController adminEmailController = TextEditingController();

  @override
  void initState() {
    initialization();
    super.initState();
  }

  void sorting () {
    setState(() {
      upSorting = !upSorting;
      usersList.sortUsersForEmail(upSorting);
    });

  }

  Future<void> createAdmin(SimpleUser user) async{

    final results = await systemMethods.pushToPageWithResult(
        context: context,
        page: ProfileScreen(admin: user.createAdminUserFromSimpleUser(), isCreate: true,)
    );

    if (results != null) {
      await initialization(fromDb: false);
    }

  }

  Future<void>initialization({bool fromDb = false}) async{

    setState(() {
      loading =  true;
    });

    usersList = await usersListClass.getDownloadedList(fromDb: fromDb);

    currentAdmin = await currentAdmin.getCurrentUser(fromDb: fromDb);

    if (fromDb) {
      //  Если обновляли с БД, выводим оповещение
      _showSnackBar(SystemConstants.refreshSuccess);
    }

    setState(() {
      loading = false;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(ScreenConstants.usersPage),
        actions: [
          // Кнопка "Обновить"
          IconButton(
            onPressed: () async {
              await initialization(fromDb: true);
            },
            icon: const Icon(FontAwesomeIcons.arrowsRotate, size: 15, color: AppColors.white,),
          ),

          // Кнопка "Сорировать"
          IconButton(
            onPressed: (){
              sorting();
            },
            icon: Icon(upSorting ? FontAwesomeIcons.sortUp : FontAwesomeIcons.sortDown, size: 15, color: AppColors.white,),
          ),
        ],
      ),
      body: Stack(
        children: [
          if (loading) const LoadingScreen(loadingText: SimpleUsersConstants.usersLoading),
          if (!loading) Column(
            children: [

              // ПОЛЕ ПОИСКА

              ElementsOfDesign.getSearchBar(
                  context: context,
                  textController: adminEmailController,
                  labelText: SystemConstants.inputNameOrEmail,
                  icon: FontAwesomeIcons.person,
                  onChanged: (value){
                    setState(() {
                      adminEmailController.text = value;
                      usersList = usersListClass.searchElementInList(adminEmailController.text);
                    });
                  },
                  onClean: () async {
                    usersList = await usersListClass.getDownloadedList(fromDb: false);
                    setState(() {
                      adminEmailController.text = '';
                    });
                  }
              ),

              // СПИСОК

              Expanded(
                child: Column(
                  children: [

                    if (usersList.isEmpty) const Expanded(
                        child: Center(
                          child: Text(SystemConstants.emptyList),
                        )
                    ),

                    if (usersList.isNotEmpty) Expanded(
                        child: ListView.builder(
                            padding: const EdgeInsets.fromLTRB(10, 0, 10, 30),
                            itemCount: usersList.length,
                            itemBuilder: (context, index) {

                              SimpleUser tempUser = usersList[index];

                              return tempUser.getUserCardInList(
                                  context: context,
                                  onTap: () async {

                                    final results = await systemMethods.pushToPageWithResult(
                                        context: context,
                                        page: SimpleUserScreen(simpleUser: tempUser)
                                    );

                                    if (results != null) {
                                      await initialization(fromDb: false);
                                    }
                                  },
                                  createAdminFunc: () async {
                                    await createAdmin(tempUser);
                                  },
                                  currentAdmin: currentAdmin
                              );

                            }
                        )
                    ),

                  ],
                ),
              ),
            ],
          )
        ],
      ),
      drawer: const CustomDrawer(),
    );
  }
}
