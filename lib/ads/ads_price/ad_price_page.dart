import 'dart:io';

import 'package:admin_dvij/ads/ads_price/ad_price.dart';
import 'package:admin_dvij/constants/system_constants.dart';
import 'package:admin_dvij/design/loading_screen.dart';
import 'package:admin_dvij/design_elements/button_state_enum.dart';
import 'package:admin_dvij/navigation/drawer_custom.dart';
import 'package:admin_dvij/system_methods/system_methods_class.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../design/app_colors.dart';
import '../../design_elements/elements_of_design.dart';
import '../../users/admin_user/admin_user_class.dart';

class AdPricePage extends StatefulWidget {
  const AdPricePage({super.key});

  @override
  State<AdPricePage> createState() => _AdPricePageState();
}

class _AdPricePageState extends State<AdPricePage> {

  SystemMethodsClass sm = SystemMethodsClass();
  AdPrice adPrice = AdPrice.empty();

  AdminUserClass currentAdminUser = AdminUserClass.empty();

  bool loading = false;
  bool canEdit = false;

  TextEditingController mainFirstSlot = TextEditingController();
  TextEditingController mainSecondSlot = TextEditingController();
  TextEditingController mainThirdSlot = TextEditingController();
  TextEditingController eventsFirstSlot = TextEditingController();
  TextEditingController eventsSecondSlot = TextEditingController();
  TextEditingController eventsThirdSlot = TextEditingController();
  TextEditingController placesFirstSlot = TextEditingController();
  TextEditingController placesSecondSlot = TextEditingController();
  TextEditingController placesThirdSlot = TextEditingController();
  TextEditingController promosFirstSlot = TextEditingController();
  TextEditingController promosSecondSlot = TextEditingController();
  TextEditingController promosThirdSlot = TextEditingController();

  String mainFirstSlotTwoWeeks = '';
  String mainSecondSlotTwoWeeks = '';
  String mainThirdSlotTwoWeeks = '';
  String eventsFirstSlotTwoWeeks = '';
  String eventsSecondSlotTwoWeeks = '';
  String eventsThirdSlotTwoWeeks = '';
  String placesFirstSlotTwoWeeks = '';
  String placesSecondSlotTwoWeeks = '';
  String placesThirdSlotTwoWeeks = '';
  String promosFirstSlotTwoWeeks = '';
  String promosSecondSlotTwoWeeks = '';
  String promosThirdSlotTwoWeeks = '';

  String mainFirstSlotFourWeeks = '';
  String mainSecondSlotFourWeeks = '';
  String mainThirdSlotFourWeeks = '';
  String eventsFirstSlotFourWeeks = '';
  String eventsSecondSlotFourWeeks = '';
  String eventsThirdSlotFourWeeks = '';
  String placesFirstSlotFourWeeks = '';
  String placesSecondSlotFourWeeks = '';
  String placesThirdSlotFourWeeks = '';
  String promosFirstSlotFourWeeks = '';
  String promosSecondSlotFourWeeks = '';
  String promosThirdSlotFourWeeks = '';

  @override
  void initState() {
    initialization();
    super.initState();
  }

  Future<void> initialization() async {
    setState(() {
      loading = true;
    });

    // Подгружаем текущего пользователя
    currentAdminUser = await currentAdminUser.getCurrentUser(fromDb: false);

    adPrice = await adPrice.getFromDb();

    setFields();

    setState(() {
      loading = false;
    });
  }

  void setFields(){
    mainFirstSlot.text = adPrice.mainFirstSlot.toString();
    mainSecondSlot.text = adPrice.mainSecondSlot.toString();
    mainThirdSlot.text = adPrice.mainThirdSlot.toString();
    eventsFirstSlot.text = adPrice.eventsFirstSlot.toString();
    eventsSecondSlot.text = adPrice.eventsSecondSlot.toString();
    eventsThirdSlot.text = adPrice.eventsThirdSlot.toString();
    placesFirstSlot.text = adPrice.placesFirstSlot.toString();
    placesSecondSlot.text = adPrice.placesSecondSlot.toString();
    placesThirdSlot.text = adPrice.placesThirdSlot.toString();
    promosFirstSlot.text = adPrice.promosFirstSlot.toString();
    promosSecondSlot.text = adPrice.promosSecondSlot.toString();
    promosThirdSlot.text = adPrice.promosThirdSlot.toString();

    mainFirstSlotTwoWeeks = sm.applyDiscountAndRoundUp(
        int.tryParse(mainFirstSlot.text) ?? 0,
        10
    ).toString();
    mainSecondSlotTwoWeeks = sm.applyDiscountAndRoundUp(
        int.tryParse(mainSecondSlot.text) ?? 0,
        10
    ).toString();
    mainThirdSlotTwoWeeks = sm.applyDiscountAndRoundUp(
        int.tryParse(mainThirdSlot.text) ?? 0,
        10
    ).toString();
    eventsFirstSlotTwoWeeks = sm.applyDiscountAndRoundUp(
        int.tryParse(eventsFirstSlot.text) ?? 0,
        10
    ).toString();
    eventsSecondSlotTwoWeeks = sm.applyDiscountAndRoundUp(
        int.tryParse(eventsSecondSlot.text) ?? 0,
        10
    ).toString();
    eventsThirdSlotTwoWeeks = sm.applyDiscountAndRoundUp(
        int.tryParse(eventsThirdSlot.text) ?? 0,
        10
    ).toString();
    placesFirstSlotTwoWeeks = sm.applyDiscountAndRoundUp(
        int.tryParse(placesFirstSlot.text) ?? 0,
        10
    ).toString();
    placesSecondSlotTwoWeeks = sm.applyDiscountAndRoundUp(
        int.tryParse(placesSecondSlot.text) ?? 0,
        10
    ).toString();
    placesThirdSlotTwoWeeks = sm.applyDiscountAndRoundUp(
        int.tryParse(placesThirdSlot.text) ?? 0,
        10
    ).toString();
    promosFirstSlotTwoWeeks = sm.applyDiscountAndRoundUp(
        int.tryParse(promosFirstSlot.text) ?? 0,
        10
    ).toString();
    promosSecondSlotTwoWeeks = sm.applyDiscountAndRoundUp(
        int.tryParse(promosSecondSlot.text) ?? 0,
        10
    ).toString();
    promosThirdSlotTwoWeeks = sm.applyDiscountAndRoundUp(
        int.tryParse(promosThirdSlot.text) ?? 0,
        10
    ).toString();


    mainFirstSlotFourWeeks = sm.applyDiscountAndRoundUp(
        int.tryParse(mainFirstSlot.text) ?? 0,
        20
    ).toString();
    mainSecondSlotFourWeeks = sm.applyDiscountAndRoundUp(
        int.tryParse(mainSecondSlot.text) ?? 0,
        20
    ).toString();
    mainThirdSlotFourWeeks = sm.applyDiscountAndRoundUp(
        int.tryParse(mainThirdSlot.text) ?? 0,
        20
    ).toString();
    eventsFirstSlotFourWeeks = sm.applyDiscountAndRoundUp(
        int.tryParse(eventsFirstSlot.text) ?? 0,
        20
    ).toString();
    eventsSecondSlotFourWeeks = sm.applyDiscountAndRoundUp(
        int.tryParse(eventsSecondSlot.text) ?? 0,
        20
    ).toString();
    eventsThirdSlotFourWeeks = sm.applyDiscountAndRoundUp(
        int.tryParse(eventsThirdSlot.text) ?? 0,
        20
    ).toString();
    placesFirstSlotFourWeeks = sm.applyDiscountAndRoundUp(
        int.tryParse(placesFirstSlot.text) ?? 0,
        20
    ).toString();
    placesSecondSlotFourWeeks = sm.applyDiscountAndRoundUp(
        int.tryParse(placesSecondSlot.text) ?? 0,
        20
    ).toString();
    placesThirdSlotFourWeeks = sm.applyDiscountAndRoundUp(
        int.tryParse(placesThirdSlot.text) ?? 0,
        20
    ).toString();
    promosFirstSlotFourWeeks = sm.applyDiscountAndRoundUp(
        int.tryParse(promosFirstSlot.text) ?? 0,
        20
    ).toString();
    promosSecondSlotFourWeeks = sm.applyDiscountAndRoundUp(
        int.tryParse(promosSecondSlot.text) ?? 0,
        20
    ).toString();
    promosThirdSlotFourWeeks = sm.applyDiscountAndRoundUp(
        int.tryParse(promosThirdSlot.text) ?? 0,
        20
    ).toString();

  }

  @override
  Widget build(BuildContext context) {

    final isMobile = MediaQuery.of(context).size.width < 600; // Условие для мобильной версии

    return Scaffold(
      appBar: AppBar(
        title: const Text('Прайс на рекламу'),
        actions: [

          // КНОПКИ В AppBar

          // Кнопка "Обновить"
          IconButton(
            onPressed: () async {
              await initialization();
            },
            icon: const Icon(FontAwesomeIcons.arrowsRotate, size: 15, color: AppColors.white,),
          ),

          // Кнопка "Редактировать"
          if (currentAdminUser.adminRole.accessToEditAdPrice()) IconButton(
            onPressed: (){
              setState(() {
                canEdit = true;
              });
            },
            icon: const Icon(FontAwesomeIcons.penToSquare, size: 15, color: AppColors.white,),
          ),

        ],
      ),

      drawer: const CustomDrawer(),

      body: loading
          ? const LoadingScreen()
          : SingleChildScrollView(
        child: Center(
          child: Container(
            width: sm.getScreenWidth(neededWidth: 800),
            padding: EdgeInsets.all(isMobile ? 20 : 30),
            margin: EdgeInsets.symmetric(
                vertical: Platform.isWindows || Platform.isMacOS ? 20 : 10,
                horizontal: Platform.isWindows || Platform.isMacOS ? 0 : 10
            ),
            decoration: BoxDecoration(
              color: AppColors.greyOnBackground,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [

                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Text('Главная', style: Theme.of(context).textTheme.titleMedium,),
                ),

                // Главная 1й слот

                ElementsOfDesign.buildAdaptiveRow(
                    isMobile: isMobile,
                    children: [

                      TextField(
                          style: Theme.of(context).textTheme.bodyMedium,
                          keyboardType: TextInputType.number,
                          controller: mainFirstSlot,
                          decoration: const InputDecoration(
                            labelText: 'Главная / 1 слот / Неделя',
                            prefixIcon: Icon(
                              FontAwesomeIcons.coins,
                              size: 18,
                            ),
                          ),
                          enabled: canEdit,
                          onChanged: (text){
                            setState(() {
                              int twoWeeksPrice = sm.applyDiscountAndRoundUp(
                                  int.tryParse(text) ?? 0,
                                  10
                              ) * 2;

                              int fourWeeksPrice = sm.applyDiscountAndRoundUp(
                                  int.tryParse(text) ?? 0,
                                  20
                              ) * 4;

                              mainFirstSlotTwoWeeks = twoWeeksPrice.toString();
                              mainFirstSlotFourWeeks = fourWeeksPrice.toString();
                            });
                          }
                      ),

                      ElementsOfDesign.buildTextFieldWithoutController(
                          controllerText: mainFirstSlotTwoWeeks,
                          labelText: 'Главная / 1 слот / 2 недели',
                          canEdit: false,
                          icon: FontAwesomeIcons.coins,
                          context: context
                      ),

                      ElementsOfDesign.buildTextFieldWithoutController(
                          controllerText: mainFirstSlotFourWeeks,
                          labelText: 'Главная / 1 слот / 4 недели',
                          canEdit: false,
                          icon: FontAwesomeIcons.coins,
                          context: context
                      ),

                    ]
                ),

                // Главная 2й слот

                ElementsOfDesign.buildAdaptiveRow(
                    isMobile: isMobile,
                    children: [

                      TextField(
                          enabled: canEdit,
                          style: Theme.of(context).textTheme.bodyMedium,
                          keyboardType: TextInputType.number,
                          controller: mainSecondSlot,
                          decoration: const InputDecoration(
                            labelText: 'Главная / 2 слот / Неделя',
                            prefixIcon: Icon(
                              FontAwesomeIcons.coins,
                              size: 18,
                            ),
                          ),
                          onChanged: (text){
                            setState(() {
                              int twoWeeksPrice = sm.applyDiscountAndRoundUp(
                                  int.tryParse(text) ?? 0,
                                  10
                              ) * 2;

                              int fourWeeksPrice = sm.applyDiscountAndRoundUp(
                                  int.tryParse(text) ?? 0,
                                  20
                              ) * 4;

                              mainSecondSlotTwoWeeks = twoWeeksPrice.toString();
                              mainSecondSlotFourWeeks = fourWeeksPrice.toString();
                            });
                          }
                      ),

                      ElementsOfDesign.buildTextFieldWithoutController(
                          controllerText: mainSecondSlotTwoWeeks,
                          labelText: 'Главная / 2 слот / 2 недели',
                          canEdit: false,
                          icon: FontAwesomeIcons.coins,
                          context: context
                      ),

                      ElementsOfDesign.buildTextFieldWithoutController(
                          controllerText: mainSecondSlotFourWeeks,
                          labelText: 'Главная / 2 слот / 4 недели',
                          canEdit: false,
                          icon: FontAwesomeIcons.coins,
                          context: context
                      ),

                    ]
                ),

                // Главная 3й слот

                ElementsOfDesign.buildAdaptiveRow(
                    isMobile: isMobile,
                    children: [

                      TextField(
                          enabled: canEdit,
                          style: Theme.of(context).textTheme.bodyMedium,
                          keyboardType: TextInputType.number,
                          controller: mainThirdSlot,
                          decoration: const InputDecoration(
                            labelText: 'Главная / 3 слот / Неделя',
                            prefixIcon: Icon(
                              FontAwesomeIcons.coins,
                              size: 18,
                            ),
                          ),
                          onChanged: (text){
                            setState(() {
                              int twoWeeksPrice = sm.applyDiscountAndRoundUp(
                                  int.tryParse(text) ?? 0,
                                  10
                              ) * 2;

                              int fourWeeksPrice = sm.applyDiscountAndRoundUp(
                                  int.tryParse(text) ?? 0,
                                  20
                              ) * 4;

                              mainThirdSlotTwoWeeks = twoWeeksPrice.toString();
                              mainThirdSlotFourWeeks = fourWeeksPrice.toString();
                            });
                          }
                      ),

                      ElementsOfDesign.buildTextFieldWithoutController(
                          controllerText: mainThirdSlotTwoWeeks,
                          labelText: 'Главная / 3 слот / 2 недели',
                          canEdit: false,
                          icon: FontAwesomeIcons.coins,
                          context: context
                      ),

                      ElementsOfDesign.buildTextFieldWithoutController(
                          controllerText: mainThirdSlotFourWeeks,
                          labelText: 'Главная / 3 слот / 4 недели',
                          canEdit: false,
                          icon: FontAwesomeIcons.coins,
                          context: context
                      ),

                    ]
                ),

                Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Text('Мероприятия', style: Theme.of(context).textTheme.titleMedium,),
                ),

                // Мероприятия 1й слот

                ElementsOfDesign.buildAdaptiveRow(
                    isMobile: isMobile,
                    children: [

                      TextField(
                          enabled: canEdit,
                          style: Theme.of(context).textTheme.bodyMedium,
                          keyboardType: TextInputType.number,
                          controller: eventsFirstSlot,
                          decoration: const InputDecoration(
                            labelText: 'Мероприятия / 1 слот / Неделя',
                            prefixIcon: Icon(
                              FontAwesomeIcons.coins,
                              size: 18,
                            ),
                          ),
                          onChanged: (text){
                            setState(() {
                              int twoWeeksPrice = sm.applyDiscountAndRoundUp(
                                  int.tryParse(text) ?? 0,
                                  10
                              ) * 2;

                              int fourWeeksPrice = sm.applyDiscountAndRoundUp(
                                  int.tryParse(text) ?? 0,
                                  20
                              ) * 4;

                              eventsFirstSlotTwoWeeks = twoWeeksPrice.toString();
                              eventsFirstSlotFourWeeks = fourWeeksPrice.toString();
                            });
                          }
                      ),

                      ElementsOfDesign.buildTextFieldWithoutController(
                          controllerText: eventsFirstSlotTwoWeeks,
                          labelText: 'Мероприятия / 1 слот / 2 недели',
                          canEdit: false,
                          icon: FontAwesomeIcons.coins,
                          context: context
                      ),

                      ElementsOfDesign.buildTextFieldWithoutController(
                          controllerText: eventsFirstSlotFourWeeks,
                          labelText: 'Мероприятия / 1 слот / 4 недели',
                          canEdit: false,
                          icon: FontAwesomeIcons.coins,
                          context: context
                      ),

                    ]
                ),

                // Мероприятия 2й слот

                ElementsOfDesign.buildAdaptiveRow(
                    isMobile: isMobile,
                    children: [

                      TextField(
                          enabled: canEdit,
                          style: Theme.of(context).textTheme.bodyMedium,
                          keyboardType: TextInputType.number,
                          controller: eventsSecondSlot,
                          decoration: const InputDecoration(
                            labelText: 'Мероприятия / 2 слот / Неделя',
                            prefixIcon: Icon(
                              FontAwesomeIcons.coins,
                              size: 18,
                            ),
                          ),
                          onChanged: (text){
                            setState(() {
                              int twoWeeksPrice = sm.applyDiscountAndRoundUp(
                                  int.tryParse(text) ?? 0,
                                  10
                              ) * 2;

                              int fourWeeksPrice = sm.applyDiscountAndRoundUp(
                                  int.tryParse(text) ?? 0,
                                  20
                              ) * 4;

                              eventsSecondSlotTwoWeeks = twoWeeksPrice.toString();
                              eventsSecondSlotFourWeeks = fourWeeksPrice.toString();
                            });
                          }
                      ),

                      ElementsOfDesign.buildTextFieldWithoutController(
                          controllerText: eventsSecondSlotTwoWeeks,
                          labelText: 'Мероприятия / 2 слот / 2 недели',
                          canEdit: false,
                          icon: FontAwesomeIcons.coins,
                          context: context
                      ),

                      ElementsOfDesign.buildTextFieldWithoutController(
                          controllerText: eventsSecondSlotFourWeeks,
                          labelText: 'Мероприятия / 2 слот / 4 недели',
                          canEdit: false,
                          icon: FontAwesomeIcons.coins,
                          context: context
                      ),

                    ]
                ),

                // Мероприятия 3й слот

                ElementsOfDesign.buildAdaptiveRow(
                    isMobile: isMobile,
                    children: [

                      TextField(
                          enabled: canEdit,
                          style: Theme.of(context).textTheme.bodyMedium,
                          keyboardType: TextInputType.number,
                          controller: eventsThirdSlot,
                          decoration: const InputDecoration(
                            labelText: 'Мероприятия / 3 слот / Неделя',
                            prefixIcon: Icon(
                              FontAwesomeIcons.coins,
                              size: 18,
                            ),
                          ),
                          onChanged: (text){
                            setState(() {
                              int twoWeeksPrice = sm.applyDiscountAndRoundUp(
                                  int.tryParse(text) ?? 0,
                                  10
                              ) * 2;

                              int fourWeeksPrice = sm.applyDiscountAndRoundUp(
                                  int.tryParse(text) ?? 0,
                                  20
                              ) * 4;

                              eventsThirdSlotTwoWeeks = twoWeeksPrice.toString();
                              eventsThirdSlotFourWeeks = fourWeeksPrice.toString();
                            });
                          }
                      ),

                      ElementsOfDesign.buildTextFieldWithoutController(
                          controllerText: eventsThirdSlotTwoWeeks,
                          labelText: 'Мероприятия / 3 слот / 2 недели',
                          canEdit: false,
                          icon: FontAwesomeIcons.coins,
                          context: context
                      ),

                      ElementsOfDesign.buildTextFieldWithoutController(
                          controllerText: eventsThirdSlotFourWeeks,
                          labelText: 'Мероприятия / 3 слот / 4 недели',
                          canEdit: false,
                          icon: FontAwesomeIcons.coins,
                          context: context
                      ),

                    ]
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Text('Заведения', style: Theme.of(context).textTheme.titleMedium,),
                ),

                // Заведения 1й слот

                ElementsOfDesign.buildAdaptiveRow(
                    isMobile: isMobile,
                    children: [

                      TextField(
                          enabled: canEdit,
                          style: Theme.of(context).textTheme.bodyMedium,
                          keyboardType: TextInputType.number,
                          controller: placesFirstSlot,
                          decoration: const InputDecoration(
                            labelText: 'Заведения / 1 слот / Неделя',
                            prefixIcon: Icon(
                              FontAwesomeIcons.coins,
                              size: 18,
                            ),
                          ),
                          onChanged: (text){
                            setState(() {
                              int twoWeeksPrice = sm.applyDiscountAndRoundUp(
                                  int.tryParse(text) ?? 0,
                                  10
                              ) * 2;

                              int fourWeeksPrice = sm.applyDiscountAndRoundUp(
                                  int.tryParse(text) ?? 0,
                                  20
                              ) * 4;

                              placesFirstSlotTwoWeeks = twoWeeksPrice.toString();
                              placesFirstSlotFourWeeks = fourWeeksPrice.toString();
                            });
                          }
                      ),

                      ElementsOfDesign.buildTextFieldWithoutController(
                          controllerText: placesFirstSlotTwoWeeks,
                          labelText: 'Заведения / 1 слот / 2 недели',
                          canEdit: false,
                          icon: FontAwesomeIcons.coins,
                          context: context
                      ),

                      ElementsOfDesign.buildTextFieldWithoutController(
                          controllerText: placesFirstSlotFourWeeks,
                          labelText: 'Заведения / 1 слот / 4 недели',
                          canEdit: false,
                          icon: FontAwesomeIcons.coins,
                          context: context
                      ),

                    ]
                ),

                // Заведения 2й слот

                ElementsOfDesign.buildAdaptiveRow(
                    isMobile: isMobile,
                    children: [

                      TextField(
                          enabled: canEdit,
                          style: Theme.of(context).textTheme.bodyMedium,
                          keyboardType: TextInputType.number,
                          controller: placesSecondSlot,
                          decoration: const InputDecoration(
                            labelText: 'Заведения / 2 слот / Неделя',
                            prefixIcon: Icon(
                              FontAwesomeIcons.coins,
                              size: 18,
                            ),
                          ),
                          onChanged: (text){
                            setState(() {
                              int twoWeeksPrice = sm.applyDiscountAndRoundUp(
                                  int.tryParse(text) ?? 0,
                                  10
                              ) * 2;

                              int fourWeeksPrice = sm.applyDiscountAndRoundUp(
                                  int.tryParse(text) ?? 0,
                                  20
                              ) * 4;

                              placesSecondSlotTwoWeeks = twoWeeksPrice.toString();
                              placesSecondSlotFourWeeks = fourWeeksPrice.toString();
                            });
                          }
                      ),

                      ElementsOfDesign.buildTextFieldWithoutController(
                          controllerText: placesSecondSlotTwoWeeks,
                          labelText: 'Заведения / 2 слот / 2 недели',
                          canEdit: false,
                          icon: FontAwesomeIcons.coins,
                          context: context
                      ),

                      ElementsOfDesign.buildTextFieldWithoutController(
                          controllerText: placesSecondSlotFourWeeks,
                          labelText: 'Заведения / 2 слот / 4 недели',
                          canEdit: false,
                          icon: FontAwesomeIcons.coins,
                          context: context
                      ),

                    ]
                ),

                // Заведения 3й слот

                ElementsOfDesign.buildAdaptiveRow(
                    isMobile: isMobile,
                    children: [

                      TextField(
                          enabled: canEdit,
                          style: Theme.of(context).textTheme.bodyMedium,
                          keyboardType: TextInputType.number,
                          controller: placesThirdSlot,
                          decoration: const InputDecoration(
                            labelText: 'Заведения / 3 слот / Неделя',
                            prefixIcon: Icon(
                              FontAwesomeIcons.coins,
                              size: 18,
                            ),
                          ),
                          onChanged: (text){
                            setState(() {
                              int twoWeeksPrice = sm.applyDiscountAndRoundUp(
                                  int.tryParse(text) ?? 0,
                                  10
                              ) * 2;

                              int fourWeeksPrice = sm.applyDiscountAndRoundUp(
                                  int.tryParse(text) ?? 0,
                                  20
                              ) * 4;

                              placesThirdSlotTwoWeeks = twoWeeksPrice.toString();
                              placesThirdSlotFourWeeks = fourWeeksPrice.toString();
                            });
                          }
                      ),

                      ElementsOfDesign.buildTextFieldWithoutController(
                          controllerText: placesThirdSlotTwoWeeks,
                          labelText: 'Заведения / 3 слот / 2 недели',
                          canEdit: false,
                          icon: FontAwesomeIcons.coins,
                          context: context
                      ),

                      ElementsOfDesign.buildTextFieldWithoutController(
                          controllerText: placesThirdSlotFourWeeks,
                          labelText: 'Заведения / 3 слот / 4 недели',
                          canEdit: false,
                          icon: FontAwesomeIcons.coins,
                          context: context
                      ),

                    ]
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Text('Акции', style: Theme.of(context).textTheme.titleMedium,),
                ),

                // Акции 1й слот

                ElementsOfDesign.buildAdaptiveRow(
                    isMobile: isMobile,
                    children: [

                      TextField(
                          enabled: canEdit,
                          style: Theme.of(context).textTheme.bodyMedium,
                          keyboardType: TextInputType.number,
                          controller: promosFirstSlot,
                          decoration: const InputDecoration(
                            labelText: 'Акции / 1 слот / Неделя',
                            prefixIcon: Icon(
                              FontAwesomeIcons.coins,
                              size: 18,
                            ),
                          ),
                          onChanged: (text){
                            setState(() {
                              int twoWeeksPrice = sm.applyDiscountAndRoundUp(
                                  int.tryParse(text) ?? 0,
                                  10
                              ) * 2;

                              int fourWeeksPrice = sm.applyDiscountAndRoundUp(
                                  int.tryParse(text) ?? 0,
                                  20
                              ) * 4;

                              promosFirstSlotTwoWeeks = twoWeeksPrice.toString();
                              promosFirstSlotFourWeeks = fourWeeksPrice.toString();
                            });
                          }
                      ),

                      ElementsOfDesign.buildTextFieldWithoutController(
                          controllerText: promosFirstSlotTwoWeeks,
                          labelText: 'Акции / 1 слот / 2 недели',
                          canEdit: false,
                          icon: FontAwesomeIcons.coins,
                          context: context
                      ),

                      ElementsOfDesign.buildTextFieldWithoutController(
                          controllerText: promosFirstSlotFourWeeks,
                          labelText: 'Акции / 1 слот / 4 недели',
                          canEdit: false,
                          icon: FontAwesomeIcons.coins,
                          context: context
                      ),

                    ]
                ),

                // Заведения 2й слот

                ElementsOfDesign.buildAdaptiveRow(
                    isMobile: isMobile,
                    children: [

                      TextField(
                          enabled: canEdit,
                          style: Theme.of(context).textTheme.bodyMedium,
                          keyboardType: TextInputType.number,
                          controller: promosSecondSlot,
                          decoration: const InputDecoration(
                            labelText: 'Акции / 2 слот / Неделя',
                            prefixIcon: Icon(
                              FontAwesomeIcons.coins,
                              size: 18,
                            ),
                          ),
                          onChanged: (text){
                            setState(() {
                              int twoWeeksPrice = sm.applyDiscountAndRoundUp(
                                  int.tryParse(text) ?? 0,
                                  10
                              ) * 2;

                              int fourWeeksPrice = sm.applyDiscountAndRoundUp(
                                  int.tryParse(text) ?? 0,
                                  20
                              ) * 4;

                              promosSecondSlotTwoWeeks = twoWeeksPrice.toString();
                              promosSecondSlotFourWeeks = fourWeeksPrice.toString();
                            });
                          }
                      ),

                      ElementsOfDesign.buildTextFieldWithoutController(
                          controllerText: promosSecondSlotTwoWeeks,
                          labelText: 'Акции / 2 слот / 2 недели',
                          canEdit: false,
                          icon: FontAwesomeIcons.coins,
                          context: context
                      ),

                      ElementsOfDesign.buildTextFieldWithoutController(
                          controllerText: promosSecondSlotFourWeeks,
                          labelText: 'Акции / 2 слот / 4 недели',
                          canEdit: false,
                          icon: FontAwesomeIcons.coins,
                          context: context
                      ),

                    ]
                ),

                // Заведения 3й слот

                ElementsOfDesign.buildAdaptiveRow(
                    isMobile: isMobile,
                    children: [

                      TextField(
                          enabled: canEdit,
                          style: Theme.of(context).textTheme.bodyMedium,
                          keyboardType: TextInputType.number,
                          controller: promosThirdSlot,
                          decoration: const InputDecoration(
                            labelText: 'Акции / 3 слот / Неделя',
                            prefixIcon: Icon(
                              FontAwesomeIcons.coins,
                              size: 18,
                            ),
                          ),
                          onChanged: (text){
                            setState(() {
                              int twoWeeksPrice = sm.applyDiscountAndRoundUp(
                                  int.tryParse(text) ?? 0,
                                  10
                              ) * 2;

                              int fourWeeksPrice = sm.applyDiscountAndRoundUp(
                                  int.tryParse(text) ?? 0,
                                  20
                              ) * 4;

                              promosThirdSlotTwoWeeks = twoWeeksPrice.toString();
                              promosThirdSlotFourWeeks = fourWeeksPrice.toString();
                            });
                          }
                      ),

                      ElementsOfDesign.buildTextFieldWithoutController(
                          controllerText: promosThirdSlotTwoWeeks,
                          labelText: 'Акции / 3 слот / 2 недели',
                          canEdit: false,
                          icon: FontAwesomeIcons.coins,
                          context: context
                      ),

                      ElementsOfDesign.buildTextFieldWithoutController(
                          controllerText: promosThirdSlotFourWeeks,
                          labelText: 'Акции / 3 слот / 4 недели',
                          canEdit: false,
                          icon: FontAwesomeIcons.coins,
                          context: context
                      ),

                    ]
                ),

                if (canEdit) const SizedBox(height: 20,),

                if (canEdit) ElementsOfDesign.buildAdaptiveRow(
                    isMobile: isMobile,
                    children: [
                      ElementsOfDesign.customButton(
                          method: () async {
                            await savePrice();
                          },
                          textOnButton: 'Сохранить',
                          context: context
                      ),
                      ElementsOfDesign.customButton(
                          method: (){
                            setFields();
                            setState(() {
                              canEdit = false;
                            });
                          },
                          textOnButton: 'Отменить',
                          context: context,
                        buttonState: ButtonStateEnum.secondary
                      )
                    ]
                ),
              ],
            ),
          ),
        ),
      ),

    );
  }

  Future<void> savePrice()async {
    AdPrice savedAdPrice = AdPrice(
        mainFirstSlot: int.tryParse(mainFirstSlot.text) ?? 0,
        mainSecondSlot: int.tryParse(mainSecondSlot.text) ?? 0,
        mainThirdSlot: int.tryParse(mainThirdSlot.text) ?? 0,
        eventsFirstSlot: int.tryParse(eventsFirstSlot.text) ?? 0,
        eventsSecondSlot: int.tryParse(eventsSecondSlot.text) ?? 0,
        eventsThirdSlot: int.tryParse(eventsThirdSlot.text) ?? 0,
        placesFirstSlot: int.tryParse(placesFirstSlot.text) ?? 0,
        placesSecondSlot: int.tryParse(placesSecondSlot.text) ?? 0,
        placesThirdSlot: int.tryParse(placesThirdSlot.text) ?? 0,
        promosFirstSlot: int.tryParse(promosFirstSlot.text) ?? 0,
        promosSecondSlot: int.tryParse(promosSecondSlot.text) ?? 0,
        promosThirdSlot: int.tryParse(promosThirdSlot.text) ?? 0,
    );

    String result = await savedAdPrice.publishToDb();

    if (result == SystemConstants.successConst){
      await initialization();
      setState(() {
        canEdit = false;
      });
    }

  }

  void navigateToPreviousScreen(){
    List<dynamic> result = [true];
    sm.popBackToPreviousPageWithResult(context: context, result: result);
  }

}
