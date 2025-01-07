import 'package:admin_dvij/constants/admins_constants.dart';
import 'package:admin_dvij/constants/buttons_constants.dart';
import 'package:admin_dvij/users/admin_user/admin_user_class.dart';
import 'package:admin_dvij/users/admin_user/admin_users_list.dart';
import 'package:admin_dvij/users/admin_user/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../constants/screen_constants.dart';
import '../../constants/system_constants.dart';
import '../../design/app_colors.dart';
import '../../design/loading_screen.dart';
import '../../design_elements/elements_of_design.dart';
import '../../navigation/drawer_custom.dart';
import '../../system_methods/system_methods_class.dart';

class AdminsListScreen extends StatefulWidget {
  const AdminsListScreen({Key? key}) : super(key: key);

  @override
  State<AdminsListScreen> createState() => _AdminsListScreenState();
}

class _AdminsListScreenState extends State<AdminsListScreen> {

  AdminUsersListClass adminsListClass = AdminUsersListClass();
  List<AdminUserClass> adminsList = [];

  AdminUserClass currentAdmin = AdminUserClass.empty();

  SystemMethodsClass systemMethods = SystemMethodsClass();

  bool loading = false;
  bool deleting = false;
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

  void sorting () {
    setState(() {
      upSorting = !upSorting;
      adminsList.sortAdminsForEmail(upSorting);
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
          if (loading) const LoadingScreen(loadingText: AdminConstants.adminsLoading)
          else if (deleting) const LoadingScreen(loadingText: 'Удаление пользователя')
          else Column(
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
                    adminsList = adminsListClass.searchElementInList(adminEmailController.text);
                  });
                },
                onClean: () async {
                  adminsList = await adminsListClass.getDownloadedList(fromDb: false);
                  setState(() {
                    adminEmailController.text = '';
                  });
                },
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

                              return tempAdmin.getAdminCardInList(
                                  onTap: () async {
                                    await editAdmin(tempAdmin);
                                  },
                                  onDelete: () async {
                                    await deleteAdmin(admin: tempAdmin);
                                  },
                                  context: context
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

  Future<void> deleteAdmin ({required AdminUserClass admin}) async {
    bool? confirmed = await ElementsOfDesign.exitDialog(
        context,
        'Восстановить данные администратора нельзя',
        ButtonsConstants.delete,
        ButtonsConstants.cancel,
        'Удалить администратора ${admin.getFullName()}?'
    );

    if (confirmed != null && confirmed){
      setState(() {
        deleting = true;
      });

      String result = await admin.deleteFromDb();

      if (result == SystemConstants.successConst){
        await initialization();
        _showSnackBar(SystemConstants.deletingSuccess);
      } else {
        _showSnackBar(result);
      }

      setState(() {
        deleting = false;
      });

    }

  }

  Future<void> editAdmin(AdminUserClass admin) async{

    // Уходим на страницу создания / редактирования
    // Ждем результат с нее

    final results = await systemMethods.pushToPageWithResult(
        context: context,
        page: ProfileScreen(admin: admin)
    );

    if (results != null) {
      await initialization(fromDb: false);
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
