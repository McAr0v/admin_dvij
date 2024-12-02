import 'dart:io';
import 'package:admin_dvij/auth/log_in_screen.dart';
import 'package:admin_dvij/constants/admins_constants.dart';
import 'package:admin_dvij/constants/buttons_constants.dart';
import 'package:admin_dvij/design/loading_screen.dart';
import 'package:admin_dvij/design_elements/elements_of_design.dart';
import 'package:admin_dvij/system_methods/system_methods_class.dart';
import 'package:admin_dvij/users/admin_user/admin_user_class.dart';
import 'package:admin_dvij/users/roles/admins_roles_class.dart';
import 'package:flutter/material.dart';
import '../design_elements/logo_view.dart';
import '../main_page/main_screen.dart';

class AccessPage extends StatefulWidget {
  const AccessPage({Key? key}) : super(key: key);

  @override
  State<AccessPage> createState() => _AccessPageState();
}

class _AccessPageState extends State<AccessPage> {

  SystemMethodsClass sm = SystemMethodsClass();

  AdminUserClass currentAdmin = AdminUserClass.empty();

  bool loading = false;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init () async {

    setState(() {
      loading = true;
    });

    currentAdmin = await currentAdmin.getCurrentUserFromDb();

    // Если у пользователя есть доступ, отправляем его на главную страницу
    if (currentAdmin.adminRole.adminRole != AdminRole.viewer && currentAdmin.adminRole.adminRole != AdminRole.notChosen){
      await navigateToMainPage();
    }

    setState(() {
      loading = false;
    });

  }

  Future<void> navigateToMainPage()async {

    await sm.pushAndDeletePreviousPages(context: context, page: const MainPageCustom());

  }

  Future<void> navigateToLogIn()async {

    await sm.pushAndDeletePreviousPages(context: context, page: const LogInScreen());

  }

  @override
  Widget build(BuildContext context) {

    // Ограничение ширины на настольных платформах
    bool isDesktop = Platform.isWindows || Platform.isMacOS || Platform.isLinux;
    double maxWidth = isDesktop ? 600 : double.infinity;

    return Scaffold(
      body: Stack(
        children: [
          if (loading) const LoadingScreen(loadingText: AdminConstants.checkingAdmin)
          else Center(
            child: Container(
              width: maxWidth,
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,

                children: [
                  const LogoView(width: 70, height: 70,),

                  const SizedBox(height: 50,),

                  const Text(AdminConstants.noAccess, textAlign: TextAlign.center,),

                  const SizedBox(height: 50,),

                  ElementsOfDesign.customButton(
                      method: () async {
                        await currentAdmin.signOut();
                        await navigateToLogIn();
                      },
                      textOnButton: ButtonsConstants.logOut,
                      context: context
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
