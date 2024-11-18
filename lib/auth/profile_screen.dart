import 'package:admin_dvij/admin_user/admin_user_class.dart';
import 'package:admin_dvij/auth/auth_class.dart';
import 'package:admin_dvij/auth/log_in_screen.dart';
import 'package:admin_dvij/database/database_class.dart';
import 'package:admin_dvij/design/loading_screen.dart';
import 'package:admin_dvij/navigation/drawer_custom.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../constants/system_constants.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  AuthClass authClass = AuthClass();
  DatabaseClass database = DatabaseClass();

  User? currentUser;

  AdminUserClass currentUserAdmin = AdminUserClass.empty();

  bool loading = false;

  @override
  void initState() {
    currentUser = authClass.auth.currentUser;

    getAdmin();

    super.initState();
  }

  Future<void> getAdmin() async{
    setState(() {

      loading = true;

    });

    if (currentUser != null) {
      print(currentUser!.uid);
      DataSnapshot? snapshot = await database.getInfoFromDb('users/${currentUser!.uid}/user_info');

      if (snapshot != null && snapshot.exists) {
        print('ko');
        currentUserAdmin = AdminUserClass.fromSnapshot(snapshot);
      }

    }

    setState(() {

      loading = false;

    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ваш профиль'),
      ),
      body: Container(
        padding: EdgeInsets.all(20),
        child: Stack(
          children: [
            if (loading) const LoadingScreen(loadingText: 'Идет загрузка данных'),
            if (!loading) Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  if (currentUserAdmin.name.isNotEmpty) Text(currentUserAdmin.name),

                  Text(currentUser != null ? currentUser!.uid : 'Нет UID', style: Theme.of(context).textTheme.bodyMedium),

                  SizedBox(height: 50,),

                  TextButton(
                      onPressed: (){
                        _singOut();
                      },
                      child: Text('Выйти', style: TextStyle(fontSize: 15),)
                  )

                ],
              ),
            ),
          ],
        ),
      ),
      drawer: CustomDrawer(),
    );
  }

  void _singOut() async {
    String? signOut = await authClass.signOut();
    if (signOut == SystemConstants.successConst){
      await navigateToLogIn();
    }

  }

  Future<void> navigateToLogIn()async {
    await Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
          builder: (context) => const LogInScreen(),
      ),
        (_) => false
    );
  }
}
