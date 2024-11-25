import 'dart:io';
import 'package:admin_dvij/auth/auth_class.dart';
import 'package:admin_dvij/auth/log_in_screen.dart';
import 'package:admin_dvij/database/database_class.dart';
import 'package:admin_dvij/design/loading_screen.dart';
import 'package:admin_dvij/navigation/drawer_custom.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import '../constants/system_constants.dart';
import '../users/admin_user/admin_user_class.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  AdminUserClass currentUserAdmin = AdminUserClass.empty();

  bool loading = false;

  @override
  void initState() {

    getAdmin();

    super.initState();
  }

  Future<void> getAdmin() async{
    setState(() {

      loading = true;

    });

    currentUserAdmin = await currentUserAdmin.getCurrentUser();

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
      body: Stack(
        
        children: [
          if (loading) const LoadingScreen(loadingText: 'Идет загрузка данных'),
          if (!loading) Container(
            padding: EdgeInsets.all(50),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
            
                  if (currentUserAdmin.name.isNotEmpty) Text(currentUserAdmin.getFullName()),
            
                  if (currentUserAdmin.email.isNotEmpty) Text(currentUserAdmin.email),
                  if (currentUserAdmin.email.isNotEmpty) Text(currentUserAdmin.adminRole.getNameOrDescOfRole(true)),
                  if (currentUserAdmin.email.isNotEmpty) Text(currentUserAdmin.adminRole.getNameOrDescOfRole(false)),
                  if (currentUserAdmin.email.isNotEmpty) Text(currentUserAdmin.city.name),
                  if (currentUserAdmin.avatar.isNotEmpty) CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey, // Цвет фона, который будет виден во время загрузки
                    child: ClipOval(
                      child: FadeInImage(
                        placeholder: const AssetImage('assets/u_user.png'),
                        image: NetworkImage(currentUserAdmin.avatar),
                        fit: BoxFit.cover,
                        width: 100,
                        height: 100,
                        imageErrorBuilder: (context, error, stackTrace) {
                          return Image.asset('assets/error_image.png'); // Изображение ошибки, если загрузка не удалась
                        },
                      ),
                    ),
                  ),
            
                  if (currentUserAdmin.registrationDate != DateTime(2100)) Text(currentUserAdmin.registrationDate.toString()),
                  if (currentUserAdmin.registrationDate != DateTime(2100)) Text(currentUserAdmin.birthDate.toString()),

                  //Text(currentUser != null ? currentUser!.uid : 'Нет UID', style: Theme.of(context).textTheme.bodyMedium),
            
                  SizedBox(height: 50,),
            
                  TextButton(
                      onPressed: (){
                        _singOut();

                      },
                      child: Text('Выйти', style: TextStyle(fontSize: 15),)
                  ),
                  TextButton(
                      onPressed: () async{
                        await getAdmin();
                      },
                      child: Text('загрузить данные', style: TextStyle(fontSize: 15),)
                  )
            
                ],
              ),
            ),
          ),
        ],
      ),
      drawer: CustomDrawer(),
    );
  }

  void _singOut() async {
    String? signOut = await currentUserAdmin.signOut();
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
