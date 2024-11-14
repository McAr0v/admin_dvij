import 'dart:io';

import 'package:admin_dvij/auth/profile_screen.dart';
import 'package:admin_dvij/design/app_colors.dart';
import 'package:admin_dvij/main_page/main_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../design_elements/logo_view.dart';

class CustomDrawer extends StatefulWidget {
  const CustomDrawer({Key? key}) : super(key: key);

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {

  double switchDrawerSize () {
    if (Platform.isWindows) {
      return MediaQuery.of(context).size.width * 0.3;
    } else {
      return MediaQuery.of(context).size.width * 0.8;
    }
  }

  EdgeInsetsGeometry switchDrawerPadding(){
    if (Platform.isWindows) {
      return EdgeInsets.fromLTRB(15.0, 15.0, 15.0, 15.0);
    } else {
      return EdgeInsets.fromLTRB(5.0, 50.0, 5.0, 5.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(

      // Помещаем в контейнер, чтобы окрасить в нужный цвет

      // -- Устанавливаем ширину Drawer в зависимости от ширины всего экрана
      width: switchDrawerSize(),

      child: Container(

        // Внутренние отступы
        padding: switchDrawerPadding(),
        color: AppColors.greyOnBackground,
        child: ListView(
          // ListView Чтобы все элементы шли друг за другом

          padding: const EdgeInsets.fromLTRB(5.0, 20.0, 5.0, 5.0),
          children: [

            // Отдельный виджет логотипа
            const LogoView(),

            // Дополнительные страницы - О приложении, написать разработчику и тд.

            ListTile(
              title: const Text('Главный экран'),
              leading: const Icon(Icons.feedback),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MainPageCustom()),
                );
              },
            ),

            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('Профиль'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfileScreen()),
                );
              },
            ),


            ListTile(
              leading: const Icon(Icons.ad_units),
              title: const Text('Реклама в приложении'),
              onTap: () {
                /*Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AboutAdPage()),
                );*/
              },
            ),

            ListTile(
              leading: const Icon(Icons.privacy_tip),
              title: const Text('Политика конфиденциальности'),
              onTap: () {
                /*Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const PrivacyPolicyPage()),
                );*/
              },
            ),
          ],
        ),
      ),
    );
  }
}
