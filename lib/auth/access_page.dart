import 'package:admin_dvij/auth/log_in_screen.dart';
import 'package:admin_dvij/design/loading_screen.dart';
import 'package:admin_dvij/design_elements/elements_of_design.dart';
import 'package:admin_dvij/users/admin_user/admin_user_class.dart';
import 'package:admin_dvij/users/roles/admins_roles_class.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../main_page/main_screen.dart';

class AccessPage extends StatefulWidget {
  const AccessPage({Key? key}) : super(key: key);

  @override
  State<AccessPage> createState() => _AccessPageState();
}

class _AccessPageState extends State<AccessPage> {

  AdminUserClass currentAdmin = AdminUserClass.empty();

  bool loading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    init();
  }

  Future<void> init () async {

    setState(() {
      loading = true;
    });

    currentAdmin = await currentAdmin.getCurrentUserFromDb();

    if (currentAdmin.adminRole.adminRole != AdminRole.viewer){
      await navigateToProfile();
    }

    setState(() {
      loading = false;
    });

  }

  Future<void> navigateToProfile()async {

    await Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder: (context) => const MainPageCustom()
        ),
            (_) => false
    );
  }

  Future<void> navigateToLogIn()async {

    await Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder: (context) => const LogInScreen()
        ),
            (_) => false
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          if (loading) LoadingScreen(loadingText: 'Проверка пользователя')
          else Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,

              children: [
                Text('Вы не можете просматривать админ. панель. У вас нет доступа.'),

                ElementsOfDesign.customButton(
                    method: () async {
                      await currentAdmin.signOut();
                      await navigateToLogIn();
                    },
                    textOnButton: 'Выйти',
                    context: context
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
