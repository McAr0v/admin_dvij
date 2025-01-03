import 'package:flutter/material.dart';

import 'app_colors.dart';

class CustomTheme {

  static ThemeData get darkTheme {
    return ThemeData(
      // Всплывающее оповещение

        snackBarTheme: const SnackBarThemeData(
            backgroundColor: AppColors.brandColor,
            actionTextColor: AppColors.white,
            contentTextStyle: TextStyle(
                color: AppColors.greyOnBackground,
                fontSize: 16,
                fontFamily: 'SfProDisplay',
                fontWeight: FontWeight.w400,
                height: 1.1
            )
        ),

        dialogTheme: DialogTheme(
          surfaceTintColor: Colors.transparent,

        ),

        datePickerTheme: DatePickerThemeData(
          headerBackgroundColor: Colors.transparent,
            headerHeadlineStyle: TextStyle(
              fontSize: 16
            ),
            headerHelpStyle: TextStyle(
                fontSize: 16
            ),

            headerForegroundColor: AppColors.white,
            surfaceTintColor: Colors.transparent,
            /*dayForegroundColor: MaterialStateProperty.resolveWith<Color?>(
              (Set<MaterialState> states) {
            return AppColors.greyOnBackground;
          },
        ),*/


            dayStyle: const TextStyle(
                color: AppColors.white,
                fontSize: 16,
                fontFamily: 'SfProDisplay',
                fontWeight: FontWeight.normal,
                height: 1.3
            ),


            weekdayStyle: const TextStyle(
                color: AppColors.greyText,
                fontSize: 16,
                fontFamily: 'SfProDisplay',
                fontWeight: FontWeight.normal,
                height: 1.3
            ),

            backgroundColor: AppColors.greyOnBackground,

            /*todayBackgroundColor: MaterialStateProperty.resolveWith<Color?>(
              (Set<MaterialState> states) {
            return AppColors.white;
          },
        ),*/

            cancelButtonStyle: ButtonStyle(
              backgroundColor: MaterialStateProperty.resolveWith<Color?>(
                    (Set<MaterialState> states) {
                  return Colors.transparent;
                },
              ),
              padding: MaterialStateProperty.resolveWith<EdgeInsets?>(
                    (Set<MaterialState> states) {
                  return const EdgeInsets.fromLTRB(20, 10, 0, 20);
                },
              ),
              textStyle: MaterialStateProperty.resolveWith<TextStyle?>(
                    (Set<MaterialState> states) {
                  return const TextStyle(
                      fontSize: 16,
                      fontFamily: 'SfProDisplay',
                      fontWeight: FontWeight.normal,
                      height: 1.3
                  );
                },
              ),
              foregroundColor: MaterialStateProperty.resolveWith<Color?>(
                    (Set<MaterialState> states) {
                  return AppColors.attentionRed;
                },
              ),
              side: MaterialStateProperty.resolveWith<BorderSide?>(
                    (Set<MaterialState> states) {
                  return const BorderSide(
                    color: Colors.transparent, // Цвет границы
                    width: 0.0, // Толщина границы
                  );
                },
              ),
              minimumSize: MaterialStateProperty.resolveWith<Size?>(
                    (Set<MaterialState> states) {
                  return Size(0, 0); // Задайте минимальную ширину и высоту
                },
              ),
            ),
            confirmButtonStyle: ButtonStyle(
              backgroundColor: MaterialStateProperty.resolveWith<Color?>(
                    (Set<MaterialState> states) {
                  return Colors.transparent;
                },
              ),
              padding: MaterialStateProperty.resolveWith<EdgeInsets?>(
                    (Set<MaterialState> states) {
                  return const EdgeInsets.fromLTRB(20, 10, 20, 20);
                },
              ),
              textStyle: MaterialStateProperty.resolveWith<TextStyle?>(
                    (Set<MaterialState> states) {
                  return const TextStyle(
                      fontSize: 16,
                      fontFamily: 'SfProDisplay',
                      fontWeight: FontWeight.normal,
                      height: 1.3
                  );
                },
              ),
              foregroundColor: MaterialStateProperty.resolveWith<Color?>(
                    (Set<MaterialState> states) {
                  return Colors.green;
                },
              ),
              side: MaterialStateProperty.resolveWith<BorderSide?>(
                    (Set<MaterialState> states) {
                  return const BorderSide(
                    color: Colors.transparent, // Цвет границы
                    width: 0.0, // Толщина границы
                  );
                },
              ),
              minimumSize: MaterialStateProperty.resolveWith<Size?>(
                    (Set<MaterialState> states) {
                  return Size(0, 0); // Задайте минимальную ширину и высоту
                },
              ),
            ),
            /*todayForegroundColor: MaterialStateProperty.resolveWith<Color?>(
              (Set<MaterialState> states) {
            return AppColors.white;
          },
        ),*/
            todayBorder: BorderSide(style: BorderStyle.none),
        ),

        timePickerTheme: TimePickerThemeData(
          cancelButtonStyle: ButtonStyle(
            backgroundColor: MaterialStateProperty.resolveWith<Color?>(
                  (Set<MaterialState> states) {
                return Colors.transparent;
              },
            ),
            padding: MaterialStateProperty.resolveWith<EdgeInsets?>(
                  (Set<MaterialState> states) {
                return const EdgeInsets.fromLTRB(20, 10, 0, 20);
              },
            ),
            textStyle: MaterialStateProperty.resolveWith<TextStyle?>(
                  (Set<MaterialState> states) {
                return const TextStyle(
                    fontSize: 16,
                    fontFamily: 'SfProDisplay',
                    fontWeight: FontWeight.normal,
                    height: 1.3
                );
              },
            ),
            foregroundColor: MaterialStateProperty.resolveWith<Color?>(
                  (Set<MaterialState> states) {
                return AppColors.attentionRed;
              },
            ),
            side: MaterialStateProperty.resolveWith<BorderSide?>(
                  (Set<MaterialState> states) {
                return const BorderSide(
                  color: Colors.transparent, // Цвет границы
                  width: 0.0, // Толщина границы
                );
              },
            ),
            minimumSize: MaterialStateProperty.resolveWith<Size?>(
                  (Set<MaterialState> states) {
                return Size(0, 0); // Задайте минимальную ширину и высоту
              },
            ),
          ),
          confirmButtonStyle: ButtonStyle(
            backgroundColor: MaterialStateProperty.resolveWith<Color?>(
                  (Set<MaterialState> states) {
                return Colors.transparent;
              },
            ),
            padding: MaterialStateProperty.resolveWith<EdgeInsets?>(
                  (Set<MaterialState> states) {
                return const EdgeInsets.fromLTRB(20, 10, 20, 20);
              },
            ),
            textStyle: MaterialStateProperty.resolveWith<TextStyle?>(
                  (Set<MaterialState> states) {
                return const TextStyle(
                    fontSize: 16,
                    fontFamily: 'SfProDisplay',
                    fontWeight: FontWeight.normal,
                    height: 1.3
                );
              },
            ),
            foregroundColor: MaterialStateProperty.resolveWith<Color?>(
                  (Set<MaterialState> states) {
                return Colors.green;
              },
            ),
            side: MaterialStateProperty.resolveWith<BorderSide?>(
                  (Set<MaterialState> states) {
                return const BorderSide(
                  color: Colors.transparent, // Цвет границы
                  width: 0.0, // Толщина границы
                );
              },
            ),
            minimumSize: MaterialStateProperty.resolveWith<Size?>(
                  (Set<MaterialState> states) {
                return Size(0, 0); // Задайте минимальную ширину и высоту
              },
            ),
          ),
          // Стиль часов (циферблат)
          dialBackgroundColor: AppColors.greyOnBackground,
          dialTextColor: Colors.white,
          dialHandColor: Colors.green,
          dialTextStyle: const TextStyle(
            fontSize: 18,
            fontFamily: 'SfProDisplay',
            fontWeight: FontWeight.w500,
          ),



          // Стиль разделителей времени (часы и минуты)
          hourMinuteTextColor: AppColors.white,
          hourMinuteShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Colors.transparent),
          ),
          hourMinuteTextStyle: const TextStyle(
            fontSize: 20,
            fontFamily: 'SfProDisplay',
            fontWeight: FontWeight.normal,
          ),
          hourMinuteColor: AppColors.greyBackground,

          // Стиль фона заголовка
          backgroundColor: AppColors.greyOnBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),

          // Текст подсказки (например, "Выберите время")
          helpTextStyle: const TextStyle(
            fontSize: 18,
            fontFamily: 'SfProDisplay',
            fontWeight: FontWeight.w400,
            color: AppColors.white,
          ),
          dayPeriodTextColor: AppColors.brandColor,
          dayPeriodTextStyle: TextStyle(
            color: AppColors.brandColor
          ),
          timeSelectorSeparatorTextStyle: MaterialStateProperty.resolveWith<TextStyle?>(
                (Set<MaterialState> states) {
              return TextStyle(
                fontSize: 30,
                height: 2.2,

              ); // Задайте минимальную ширину и высоту
            },
          ),
          timeSelectorSeparatorColor: MaterialStateProperty.resolveWith<Color?>(
                (Set<MaterialState> states) {
              return AppColors.greyText; // Задайте минимальную ширину и высоту
            },
          ),
        ),

        // Стиль кнопки

        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            textStyle: const TextStyle(color: AppColors.white, fontSize: 16, fontFamily: 'SfProDisplay', fontWeight: FontWeight.normal),
            padding: const EdgeInsets.all(10.0),
            minimumSize: const Size(double.infinity, 50),
            backgroundColor: AppColors.brandColor,
            foregroundColor: AppColors.greyOnBackground,
            side: const BorderSide(color: AppColors.brandColor, width: 2.0), // Добавлено границу кнопки
          ),

        ),

        // Верхняя панель

        appBarTheme: const AppBarTheme(
          // Настройка, чтобы при прокрутке не менялся цвет панели
          scrolledUnderElevation: 0.0,
          backgroundColor: AppColors.greyOnBackground,
          titleTextStyle: TextStyle(color: AppColors.white, fontSize: 22, fontFamily: 'SfProDisplay', fontWeight: FontWeight.bold),

        ),


        // Панель табов (мои, избранные, лента)

        tabBarTheme: const TabBarTheme(
          labelStyle: TextStyle(color: AppColors.brandColor, fontSize: 16, fontFamily: 'SfProDisplay', fontWeight: FontWeight.normal),
          unselectedLabelStyle: TextStyle(color: AppColors.white, fontSize: 14, fontFamily: 'SfProDisplay', fontWeight: FontWeight.normal),
          indicatorColor: AppColors.brandColor,
          indicatorSize: TabBarIndicatorSize.tab,

        ),

        primaryColor: AppColors.brandColor,

        // Цвет фона по умолчанию
        scaffoldBackgroundColor: AppColors.greyBackground,

        // Шрифты
        textTheme: const TextTheme(

            displayLarge: TextStyle(
              color: AppColors.white,
              fontSize: 35,
              fontFamily: 'SfProDisplay',
              fontWeight: FontWeight.bold,
            ),

            displayMedium: TextStyle(
              color: AppColors.white,
              fontSize: 20,
              fontFamily: 'SfProDisplay',
              fontWeight: FontWeight.bold,
            ),

            displaySmall: TextStyle(
              color: AppColors.white,
              fontSize: 16,
              fontFamily: 'SfProDisplay',
              fontWeight: FontWeight.bold,
            ),

            // Заголовки
            titleLarge: TextStyle(
                color: AppColors.white,
                fontSize: 40,
                fontFamily: 'SfProDisplay',
                fontWeight: FontWeight.w900,
                height: 1
            ),

            titleMedium: TextStyle(
                color: AppColors.white,
                fontSize: 20,
                fontFamily: 'SfProDisplay',
                fontWeight: FontWeight.bold,
                height: 1
            ),

            titleSmall: TextStyle(
              color: AppColors.white,
              fontSize: 20,
              fontFamily: 'SfProDisplay',
              fontWeight: FontWeight.normal,
            ),

            // Обычный текст
            bodyLarge: TextStyle(
              color: AppColors.white,
              fontSize: 16,
              fontFamily: 'SfProDisplay',
              fontWeight: FontWeight.bold,
            ),

            bodyMedium: TextStyle(
                color: AppColors.white,
                fontSize: 16,
                fontFamily: 'SfProDisplay',
                fontWeight: FontWeight.normal,
                height: 1.2
            ),

            bodySmall: TextStyle(
              color: AppColors.white,
              fontSize: 14,
              fontFamily: 'SfProDisplay',
              fontWeight: FontWeight.normal,
            ),

            // Мини надписи
            labelLarge: TextStyle(
              color: AppColors.white,
              fontSize: 18,
              fontFamily: 'SfProDisplay',
              fontWeight: FontWeight.normal,
            ),

            labelMedium: TextStyle(
              color: AppColors.white,
              fontSize: 12,
              fontFamily: 'SfProDisplay',
              fontWeight: FontWeight.normal,
            ),

            labelSmall: TextStyle(
              color: AppColors.white,
              fontSize: 10,
              fontFamily: 'SfProDisplay',
              fontWeight: FontWeight.normal,
            )

        ),

        // Поля ввода
        inputDecorationTheme: const InputDecorationTheme(

            labelStyle: TextStyle(
              color: AppColors.greyText,
              fontSize: 16,
              fontFamily: 'SfProDisplay',
              fontWeight: FontWeight.normal,

            ),

            floatingLabelStyle: TextStyle(
              color: AppColors.greyText,
              fontSize: 16,
              fontFamily: 'SfProDisplay',
              fontWeight: FontWeight.normal,

            ),

            hintStyle: TextStyle(
              color: AppColors.white,
              fontSize: 16,
              fontFamily: 'SfProDisplay',
              fontWeight: FontWeight.normal,

            ),

            // иконка слева
            prefixIconColor: AppColors.greyText,

            // фон поля ввода
            filled: true,
            fillColor: AppColors.greyBackground,

            // цвет активных элементов
            focusColor: AppColors.brandColor,

            // Активная граница
            border: OutlineInputBorder(
              borderSide: BorderSide(
                color: AppColors.brandColor, // Цвет границы
                width: 2.0, // Ширина границы
              ),
              borderRadius: BorderRadius.all(Radius.circular(15.0)), // Радиус скругления углов
            ),

            // Не активная граница
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: AppColors.greyText, // Цвет границы
                width: 2.0, // Ширина границы
              ),
              borderRadius: BorderRadius.all(Radius.circular(15.0)), // Радиус скругления углов
            ),

            disabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: AppColors.greyText, // Цвет границы
                width: 2.0, // Ширина границы
              ),
              borderRadius: BorderRadius.all(Radius.circular(15.0)), // Радиус скругления углов
            )


        ),

        // Цветовая схема
        colorScheme: const ColorScheme.dark(
            primary: AppColors.brandColor,
            secondary: AppColors.attentionRed,
            background: AppColors.greyBackground,
            onBackground: AppColors.greyOnBackground,
            onPrimary: AppColors.greyOnBackground,
            onSurface: AppColors.white
        ),

        // Стиль кнопки
        buttonTheme: ButtonThemeData( // 4
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          buttonColor: AppColors.brandColor,
          textTheme: ButtonTextTheme.normal,

        ),

        // Стиль нижнего меню

        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.greyOnBackground,
          selectedItemColor: AppColors.brandColor,
          unselectedItemColor: AppColors.greyText,
          selectedLabelStyle: TextStyle(
            fontSize: 12,
            fontFamily: 'SfProDisplay',
            fontWeight: FontWeight.normal,
          ),
          selectedIconTheme: IconThemeData(
              size: 25
          ),
          unselectedIconTheme: IconThemeData(
              color: AppColors.greyText
          ),
        ),

        // Всплываюшая шторка
        drawerTheme: const DrawerThemeData(
            backgroundColor: AppColors.greyOnBackground
        ),

        // Для драйвера
        // Заголовок и иконка
        listTileTheme: const ListTileThemeData(
          textColor: AppColors.white,
          iconColor: AppColors.white,
          titleTextStyle: TextStyle(color: AppColors.white, fontSize: 16, fontFamily: 'SfProDisplay', fontWeight: FontWeight.normal),
        ),

        dialogBackgroundColor: AppColors.greyOnBackground


    );
  }

}