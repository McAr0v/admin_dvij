import 'package:admin_dvij/auth/auth_class.dart';
import 'package:admin_dvij/auth/log_in_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

  User? currentUser;

  @override
  void initState() {
    currentUser = authClass.auth.currentUser;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      color: Colors.white,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(currentUser != null ? currentUser!.uid : 'Нет UID', style: TextStyle(fontSize: 15),),

            TextButton(
                onPressed: (){
                  _singOut();
                },
                child: Text('Выйти', style: TextStyle(fontSize: 15),)
            )

          ],
        ),
      ),
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
