import 'dart:io';
import 'package:admin_dvij/ads/ads_page.dart';
import 'package:admin_dvij/categories/event_categories/event_categories_list_screen.dart';
import 'package:admin_dvij/categories/place_categories/place_categories_list_screen.dart';
import 'package:admin_dvij/categories/promo_categories/promo_categories_list_screen.dart';
import 'package:admin_dvij/events/events_page.dart';
import 'package:admin_dvij/places/places_list_screen.dart';
import 'package:admin_dvij/privacy_policy/privacy_policy_list_screen.dart';
import 'package:admin_dvij/promos/promos_page.dart';
import 'package:admin_dvij/users/admin_user/admins_list_screen.dart';
import 'package:admin_dvij/users/admin_user/profile_screen.dart';
import 'package:admin_dvij/cities/cities_list_screen.dart';
import 'package:admin_dvij/constants/screen_constants.dart';
import 'package:admin_dvij/design/app_colors.dart';
import 'package:admin_dvij/design_elements/elements_of_design.dart';
import 'package:admin_dvij/main_page/main_screen.dart';
import 'package:admin_dvij/users/simple_users/simple_users_list_screen.dart';
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
                FontAwesomeIcons.mapLocationDot,
                const CitiesListScreen(),
                context
            ),

            ElementsOfDesign.drawerListElement(
                ScreenConstants.adminsPage,
                FontAwesomeIcons.userShield,
                const AdminsListScreen(),
                context
            ),

            ElementsOfDesign.drawerListElement(
                ScreenConstants.usersPage,
                FontAwesomeIcons.users,
                const SimpleUsersListScreen(),
                context
            ),

            ElementsOfDesign.drawerListElement(
                ScreenConstants.eventsCategoriesPage,
                FontAwesomeIcons.tags,
                const EventCategoriesListScreen(),
                context
            ),

            ElementsOfDesign.drawerListElement(
                ScreenConstants.placeCategoriesPage,
                FontAwesomeIcons.tags,
                const PlaceCategoriesListScreen(),
                context
            ),

            ElementsOfDesign.drawerListElement(
                ScreenConstants.promoCategoriesPage,
                FontAwesomeIcons.tags,
                const PromoCategoriesListScreen(),
                context
            ),

            ElementsOfDesign.drawerListElement(
                ScreenConstants.adsPage,
                FontAwesomeIcons.rectangleAd,
                const AdsPage(),
                context
            ),
            ElementsOfDesign.drawerListElement(
                ScreenConstants.places,
                FontAwesomeIcons.house,
                const PlacesListScreen(),
                context
            ),
            ElementsOfDesign.drawerListElement(
                ScreenConstants.events,
                FontAwesomeIcons.champagneGlasses,
                const EventsPage(),
                context
            ),
            ElementsOfDesign.drawerListElement(
                ScreenConstants.promos,
                FontAwesomeIcons.fire,
                const PromosPage(),
                context
            ),
            ElementsOfDesign.drawerListElement(
                ScreenConstants.privacyPage,
                FontAwesomeIcons.fire,
                const PrivacyPolicyListScreen(),
                context
            ),
          ],
        ),
      ),
    );
  }
}

