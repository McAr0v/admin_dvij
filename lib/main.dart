import 'dart:io';
import 'package:admin_dvij/admin_user/admin_user_class.dart';
import 'package:admin_dvij/auth/auth_class.dart';
import 'package:admin_dvij/auth/log_in_screen.dart';
import 'package:admin_dvij/database/database_class.dart';
import 'package:admin_dvij/design/custom_theme.dart';
import 'package:admin_dvij/main_page/main_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'firebase_options.dart';

Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  AuthClass authClass = AuthClass();

  var currentUser = authClass.auth.currentUser;

  // Если Windows или MacOs, устанавливаем ограничение
  // минимального размера экрана приложения

  if (Platform.isWindows || Platform.isMacOS){

    await windowManager.ensureInitialized();

    windowManager.setMinimumSize(const Size(1024, 768));
  }

  runApp(
      MyApp(currentUser: currentUser,)
  );

}

class MyApp extends StatelessWidget {

  final User? currentUser;

  const MyApp({this.currentUser, super.key});

  Widget _swapScreen(User? user){
    if (user == null) {
      return const LogInScreen();
    } else {
      return const MainPageCustom();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dvij админ',
      theme: CustomTheme.darkTheme,
      home: _swapScreen(currentUser),
    );
  }
}
