import 'dart:io';
import 'package:admin_dvij/ads/ad_class.dart';
import 'package:admin_dvij/ads/ads_list_class.dart';
import 'package:admin_dvij/auth/access_page.dart';
import 'package:admin_dvij/auth/auth_class.dart';
import 'package:admin_dvij/auth/log_in_screen.dart';
import 'package:admin_dvij/categories/event_categories/event_categories_list.dart';
import 'package:admin_dvij/categories/place_categories/place_categories_list.dart';
import 'package:admin_dvij/categories/promo_categories/promo_categories_list.dart';
import 'package:admin_dvij/cities/cities_list_class.dart';
import 'package:admin_dvij/design/custom_theme.dart';
import 'package:admin_dvij/users/admin_user/admin_users_list.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
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

  AdminUsersListClass adminsList = AdminUsersListClass();
  await adminsList.getListFromDb();

  EventCategoriesList eventCategoriesList = EventCategoriesList();
  await eventCategoriesList.getListFromDb();

  PlaceCategoriesList placeCategoriesList = PlaceCategoriesList();
  await placeCategoriesList.getListFromDb();

  PromoCategoriesList promoCategoriesList = PromoCategoriesList();
  await promoCategoriesList.getListFromDb();

  AdsList adsList = AdsList();
  List<AdClass> tempAds = await adsList.getListFromDb();

  if (tempAds.isNotEmpty){
    for (AdClass tempAd in tempAds) {
      print(tempAd.headline);
      print('------');
    }
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
      return const AccessPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dvij админ',
      theme: CustomTheme.darkTheme,
      home: _swapScreen(currentUser),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate
        //CupertinoLocalizations.delegate
      ],
      supportedLocales: const [
        Locale('ru', 'RU'), // русская локаль
        Locale('en', 'US'), // английская локаль (если нужно)
      ],
    );
  }
}
