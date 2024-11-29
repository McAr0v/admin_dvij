import 'package:admin_dvij/constants/simple_users_constants.dart';
import 'package:admin_dvij/users/simple_users/simple_user.dart';
import 'package:admin_dvij/users/simple_users/simple_users_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../constants/screen_constants.dart';
import '../../constants/system_constants.dart';
import '../../constants/users_constants.dart';
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

  bool loading = false;
  bool upSorting = false;

  final TextEditingController adminEmailController = TextEditingController();

  @override
  void initState() {
    initialization();
    super.initState();
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
              //await initData(fromDb: true);
              await initialization(fromDb: true);
            },
            icon: const Icon(FontAwesomeIcons.arrowsRotate, size: 15, color: AppColors.white,),
          ),

          // Кнопка "Сорировать"
          IconButton(
            onPressed: (){
              //sorting();
            },
            icon: Icon(upSorting ? FontAwesomeIcons.sortUp : FontAwesomeIcons.sortDown, size: 15, color: AppColors.white,),
          ),

          // Кнопка "Создать"
          /*IconButton(
            onPressed: () async {
              await createAdmin();
            },
            icon: const Icon(FontAwesomeIcons.plus, size: 15, color: AppColors.white,),
          ),*/
        ],
      ),
      body: Stack(
        children: [
          if (loading) const LoadingScreen(loadingText: SimpleUsersConstants.usersLoading),
          if (!loading) Column(
            children: [

              // ПОЛЕ ПОИСКА

              Container(
                padding: const EdgeInsets.all(10),
                child: Row(
                  children: [

                    // Форма ввода названия
                    Expanded(
                      child: TextField(
                        style: Theme.of(context).textTheme.bodyMedium,
                        keyboardType: TextInputType.text,
                        controller: adminEmailController,
                        decoration: const InputDecoration(
                          labelText: UserConstants.email,
                          prefixIcon: Icon(Icons.place),
                        ),
                        onChanged: (value){
                          setState(() {
                            adminEmailController.text = value;
                            usersList = usersListClass.searchElementInList(adminEmailController.text);
                          });
                        },
                      ),
                    ),

                    if (adminEmailController.text.isNotEmpty) const SizedBox(width: 20,),

                    // Кнопка сброса
                    if (adminEmailController.text.isNotEmpty) IconButton(
                        onPressed: () async {
                          usersList = await usersListClass.getDownloadedList(fromDb: false);
                          setState(() {
                            adminEmailController.text = '';
                          });
                        },
                        icon: const Icon(
                          FontAwesomeIcons.x,
                          size: 15,
                        )
                    ),
                  ],
                ),
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

                              return GestureDetector(
                                onTap: () async {
                                  /*final results = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ProfileScreen(admin: tempUser,),
                                    ),
                                  );*/
                                },
                                child: Card(
                                  color: AppColors.greyOnBackground,
                                  child: Padding(
                                    padding: const EdgeInsets.all(20.0),
                                    child: Row(
                                      children: [

                                        //tempUser.getAvatar(),

                                        const SizedBox(width: 20,),

                                        Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(tempUser.getFullName()),
                                                if (currentAdmin.uid == tempUser.uid) Text('Это вы', style: Theme.of(context).textTheme.labelMedium!.copyWith(color: Colors.green),),
                                                const SizedBox(height: 5,),
                                                Text(tempUser.email, style: Theme.of(context).textTheme.labelMedium!.copyWith(color: AppColors.greyText),),
                                                //Text(tempUser.adminRole.getNameOrDescOfRole(true), style: Theme.of(context).textTheme.labelMedium!.copyWith(color: AppColors.greyText),),

                                              ],
                                            )
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              );

                            }
                        )
                    )

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
