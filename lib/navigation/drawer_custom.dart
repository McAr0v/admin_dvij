import 'dart:io';
import 'package:admin_dvij/auth/profile_screen.dart';
import 'package:admin_dvij/cities/cities_list_screen.dart';
import 'package:admin_dvij/constants/screen_constants.dart';
import 'package:admin_dvij/design/app_colors.dart';
import 'package:admin_dvij/design_elements/elements_of_design.dart';
import 'package:admin_dvij/main_page/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../design_elements/logo_view.dart';

class CustomDrawer extends StatefulWidget {
  const CustomDrawer({Key? key}) : super(key: key);

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {

  double switchDrawerSize () {
    if (Platform.isWindows || Platform.isMacOS) {
      return MediaQuery.of(context).size.width * 0.3;
    } else {
      return MediaQuery.of(context).size.width * 0.8;
    }
  }

  EdgeInsetsGeometry switchDrawerPadding(){
    if (Platform.isWindows || Platform.isMacOS) {
      return const EdgeInsets.fromLTRB(15.0, 15.0, 15.0, 15.0);
    } else {
      return const EdgeInsets.fromLTRB(5.0, 50.0, 5.0, 5.0);
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

            ElementsOfDesign.drawerListElement(
                ScreenConstants.mainPage,
                FontAwesomeIcons.house,
                const MainPageCustom(),
                context
            ),

            ElementsOfDesign.drawerListElement(
                ScreenConstants.profilePage,
                FontAwesomeIcons.user,
                const ProfileScreen(),
                context
            ),

            ElementsOfDesign.drawerListElement(
                ScreenConstants.citiesPage,
                FontAwesomeIcons.marker,
                const CitiesListScreen(),
                context
            ),
            
          ],
        ),
      ),
    );
  }
}

