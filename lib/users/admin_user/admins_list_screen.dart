import 'package:admin_dvij/constants/admins_constants.dart';
import 'package:admin_dvij/users/admin_user/admin_user_class.dart';
import 'package:admin_dvij/users/admin_user/admin_users_list.dart';
import 'package:admin_dvij/users/admin_user/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../constants/city_constants.dart';
import '../../constants/screen_constants.dart';
import '../../constants/system_constants.dart';
import '../../constants/users_constants.dart';
import '../../design/app_colors.dart';
import '../../design/loading_screen.dart';
import '../../navigation/drawer_custom.dart';

class AdminsListScreen extends StatefulWidget {
  const AdminsListScreen({Key? key}) : super(key: key);

  @override
  State<AdminsListScreen> createState() => _AdminsListScreenState();
}

class _AdminsListScreenState extends State<AdminsListScreen> {

  AdminUsersListClass adminsListClass = AdminUsersListClass();
  List<AdminUserClass> adminsList = [];

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

    adminsList = await adminsListClass.getDownloadedList(fromDb: fromDb);

    currentAdmin = await currentAdmin.getCurrentUser(fromDb: fromDb);

    if (fromDb) {
      //  Если обновляли с БД, выводим оповещение
      _showSnackBar(SystemConstants.refreshSuccess);
    }

    setState(() {
      loading = false;
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(ScreenConstants.adminsPage),
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
          if (loading) const LoadingScreen(loadingText: AdminConstants.adminsLoading),
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
                            adminsList = adminsListClass.searchElementInList(adminEmailController.text);
                          });
                        },
                      ),
                    ),

                    if (adminEmailController.text.isNotEmpty) const SizedBox(width: 20,),

                    // Кнопка сброса
                    if (adminEmailController.text.isNotEmpty) IconButton(
                        onPressed: () async {
                          adminsList = await adminsListClass.getDownloadedList(fromDb: false);
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

                    if (adminsList.isEmpty) const Expanded(
                        child: Center(
                          child: Text(SystemConstants.emptyList),
                        )
                    ),

                    if (adminsList.isNotEmpty) Expanded(
                        child: ListView.builder(
                            padding: const EdgeInsets.fromLTRB(10, 0, 10, 30),
                            itemCount: adminsList.length,
                            itemBuilder: (context, index) {

                              AdminUserClass tempAdmin = adminsList[index];

                              return GestureDetector(
                                onTap: () async {
                                  final results = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ProfileScreen(admin: tempAdmin,),
                                    ),
                                  );
                                },
                                child: Card(
                                  color: AppColors.greyOnBackground,
                                  child: Padding(
                                    padding: const EdgeInsets.all(20.0),
                                    child: Row(
                                      children: [

                                        tempAdmin.getAvatar(),

                                        const SizedBox(width: 20,),

                                        Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(tempAdmin.getFullName()),
                                                if (currentAdmin.uid == tempAdmin.uid) Text('Это вы', style: Theme.of(context).textTheme.labelMedium!.copyWith(color: Colors.green),),
                                                const SizedBox(height: 5,),
                                                Text(tempAdmin.email, style: Theme.of(context).textTheme.labelMedium!.copyWith(color: AppColors.greyText),),
                                                Text(tempAdmin.adminRole.getNameOrDescOfRole(true), style: Theme.of(context).textTheme.labelMedium!.copyWith(color: AppColors.greyText),),

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

  Future<void> createAdmin() async{

    // Уходим на страницу создания / редактирования
    // Ждем результат с нее

    final results = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfileScreen(admin: AdminUserClass.empty(),),
      ),
    );

    // Если результат есть
    if (results != null) {

      setState(() {
        loading = true;
      });

      // Обновляем список
      await initialization();

      setState(() {
        loading = false;
      });

      _showSnackBar(AdminConstants.saveSuccess);
    }
  }

  void sortingByEmail () {
    setState(() {
      upSorting = !upSorting;
      adminsList.sortAdminsForEmail(upSorting);
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

}
