import 'dart:io';
import 'package:admin_dvij/auth/access_page.dart';
import 'package:admin_dvij/auth/auth_class.dart';
import 'package:admin_dvij/auth/log_in_screen.dart';
import 'package:admin_dvij/cities/cities_list_class.dart';
import 'package:admin_dvij/design/custom_theme.dart';
import 'package:admin_dvij/main_page/main_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
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

  CitiesList citiesList = CitiesList();
  await citiesList.getListFromDb();

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
      return const AccessPage();
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
