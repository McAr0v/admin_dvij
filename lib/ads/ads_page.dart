import 'package:admin_dvij/ads/ad_class.dart';
import 'package:admin_dvij/ads/ad_view_create_edit_screen.dart';
import 'package:admin_dvij/ads/ads_enums_class/ad_index.dart';
import 'package:admin_dvij/ads/ads_enums_class/ad_location.dart';
import 'package:admin_dvij/ads/ads_enums_class/ad_status.dart';
import 'package:admin_dvij/ads/ads_list_class.dart';
import 'package:admin_dvij/ads/filter_picker.dart';
import 'package:admin_dvij/design/loading_screen.dart';
import 'package:admin_dvij/design_elements/elements_of_design.dart';
import 'package:admin_dvij/navigation/drawer_custom.dart';
import 'package:admin_dvij/system_methods/system_methods_class.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../constants/screen_constants.dart';
import '../design/app_colors.dart';
import '../design_elements/cards_elements.dart';

class AdsPage extends StatefulWidget {
  final int initialIndex;
  const AdsPage({this.initialIndex = 0, Key? key}) : super(key: key);

  @override
  State<AdsPage> createState() => _AdsPageState();
}

class _AdsPageState extends State<AdsPage> {

  SystemMethodsClass sm = SystemMethodsClass();

  bool loading = false;

  TextEditingController searchingController = TextEditingController();

  AdsList adsList = AdsList();
  List<AdClass> activeAdsList = [];
  List<AdClass> draftAdsList = [];
  List<AdClass> completedAdsList = [];

  // Переменные фильтра
  AdIndex filterSlot = AdIndex(index: AdIndexEnum.notChosen);
  AdLocation filterLocation = AdLocation(location: AdLocationEnum.notChosen);

  @override
  void initState() {
    super.initState();
    initializationAndFilter();
  }

  Future<void> resetFilter() async{
    filterSlot = AdIndex(index: AdIndexEnum.notChosen);
    filterLocation = AdLocation(location: AdLocationEnum.notChosen);
    searchingController.text = '';
    initializationAndFilter(fromDb: false, location: filterLocation.location, slot: filterSlot.index, searchingText: searchingController.text);
  }

  Future<void> initializationAndFilter({
    bool fromDb = false,
    AdLocationEnum location = AdLocationEnum.notChosen,
    AdIndexEnum slot = AdIndexEnum.notChosen,
    String searchingText = ''
  }) async{

    setState(() {
      loading = true;
    });

    activeAdsList = await adsList.getNeededAds(
        fromDb: fromDb,
      status: AdStatusEnum.active,
      location: location,
      slot: slot,
      searchingText: searchingText
    );
    draftAdsList = await adsList.getNeededAds(
        fromDb: fromDb,
        status: AdStatusEnum.draft,
        location: location,
        slot: slot,
        searchingText: searchingText
    );
    completedAdsList = await adsList.getNeededAds(
        fromDb: fromDb,
        status: AdStatusEnum.completed,
        location: location,
        slot: slot,
        searchingText: searchingText
    );

    setState(() {
      loading = false;
    });

  }

  Future<void> filterAds() async{

    final result = await sm.getPopup(
        context: context,
        page: FilterPicker(location: filterLocation, slot: filterSlot)
    );

    if (result != null){
      filterLocation = result[0];
      filterSlot = result[1];

      await initializationAndFilter(location: filterLocation.location, slot: filterSlot.index, searchingText: searchingController.text);

    }

  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: widget.initialIndex,
        length: 3,
        child: Stack(
          children: [
            if (loading) LoadingScreen(loadingText: 'Идет загрузка рекламы',),
            if (!loading) Scaffold(
              appBar: AppBar(
                title: Text(
                  ScreenConstants.adsPage,
                ),
                actions: [

                  // КНОПКИ В AppBar

                  // Кнопка "Фильтр"

                  Row(
                    children: [
                      if (filterLocation.location != AdLocationEnum.notChosen || filterSlot.index != AdIndexEnum.notChosen)
                        ElementsOfDesign.linkButton(
                            method: () async {
                              await resetFilter();
                            },
                            text: 'Сбросить',
                            context: context
                        ),
                      if (filterLocation.location != AdLocationEnum.notChosen || filterSlot.index != AdIndexEnum.notChosen)
                        const SizedBox(width: 10,),
                      IconButton(
                        onPressed: () async {
                          await filterAds();
                        },
                        icon: Icon(
                          FontAwesomeIcons.filter,
                          size: 15,
                          color: filterLocation.location != AdLocationEnum.notChosen || filterSlot.index != AdIndexEnum.notChosen ? AppColors.brandColor : AppColors.white,),
                      ),
                    ],
                  ),

                  // Кнопка "Обновить"
                  IconButton(
                    onPressed: () async {
                      await initializationAndFilter(fromDb: true, slot: filterSlot.index, location: filterLocation.location, searchingText: searchingController.text);
                    },
                    icon: const Icon(FontAwesomeIcons.arrowsRotate, size: 15, color: AppColors.white,),
                  ),

                  // Кнопка "Создать"
                  IconButton(
                    onPressed: () async {
                      final result = await sm.pushToPageWithResult(context: context, page: const AdViewCreateEditScreen(indexTabPage: 0));
                      if (result != null){
                        await initializationAndFilter(fromDb: false, slot: filterSlot.index, location: filterLocation.location, searchingText: searchingController.text );
                      }
                    },
                    icon: const Icon(FontAwesomeIcons.plus, size: 15, color: AppColors.white,),
                  ),



                ],
                bottom: const TabBar(
                  tabs: [
                    Tab(
                      child: Row(
                        children: [
                          Icon(FontAwesomeIcons.fire, size: 15,),
                          SizedBox(width: 10,),
                          Text('Активные', style: TextStyle(fontSize: 13),),

                        ],
                        mainAxisAlignment: MainAxisAlignment.center,
                      ),
                    ),
                    Tab(
                      child: Row(
                        children: [
                          Icon(FontAwesomeIcons.fileLines, size: 15,),
                          SizedBox(width: 10, ),
                          Text('Черновики', style: TextStyle(fontSize: 13),),

                        ],
                        mainAxisAlignment: MainAxisAlignment.center,
                      ),
                    ),
                    Tab(
                      child: Row(
                        children: [
                          Icon(FontAwesomeIcons.circleCheck, size: 15,),
                          SizedBox(width: 10,),
                          Text('Завершенные', style: TextStyle(fontSize: 13),),

                        ],
                        mainAxisAlignment: MainAxisAlignment.center,
                      ),
                    ),
                  ],
                ),
              ),
              body: Column(
                children: [
                  ElementsOfDesign.getSearchBar(
                      context: context,
                      textController: searchingController,
                      labelText: 'Название, заказчик, слот, локация...',
                      icon: FontAwesomeIcons.searchengin,
                      onChanged: (value) async {
                        searchingController.text = value;

                        await initializationAndFilter(
                            fromDb: false,
                            location: filterLocation.location,
                          slot: filterSlot.index,
                          searchingText: value,
                        );

                      },
                      onClean: () async{
                        searchingController.text = '';
                        await initializationAndFilter(
                            fromDb: false,
                            location: filterLocation.location,
                            slot: filterSlot.index,
                            searchingText: searchingController.text,
                        );
                      }
                  ),
                  Expanded(
                    child: TabBarView(
                        children: [
                          ListView.builder(
                              padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                              itemCount: activeAdsList.length,
                              itemBuilder: (context, index) {

                                AdClass tempAd = activeAdsList[index];

                                return CardsElements.getCard(
                                    context: context,
                                    onTap: () async {
                                      await editAds(ad: tempAd, tabIndex: 0);
                                    },
                                    imageUrl: tempAd.imageUrl,
                                    widget: tempAd.getInfoWidget(context: context),
                                  leftTopTag: tempAd.status.getStatusWidget(context: context)
                                );

                              }
                          ),
                          ListView.builder(
                              padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                              itemCount: draftAdsList.length,
                              itemBuilder: (context, index) {

                                AdClass tempAd = draftAdsList[index];
                                return  CardsElements.getCard(
                                    context: context,
                                    onTap: () async {
                                      await editAds(ad: tempAd, tabIndex: 1);
                                    },
                                    imageUrl: tempAd.imageUrl,
                                    widget: tempAd.getInfoWidget(context: context),
                                    leftTopTag: tempAd.status.getStatusWidget(context: context)
                                );

                              }
                          ),
                          ListView.builder(
                              padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                              itemCount: completedAdsList.length,
                              itemBuilder: (contextOnCard, index) {

                                AdClass tempAd = completedAdsList[index];

                                return CardsElements.getCard(
                                    context: context,
                                    onTap: () async {
                                      await editAds(ad: tempAd, tabIndex: 2);
                                    },
                                    imageUrl: tempAd.imageUrl,
                                    widget: tempAd.getInfoWidget(context: context),
                                    leftTopTag: tempAd.status.getStatusWidget(context: context)
                                );

                              }
                          ),
                        ]
                    ),
                  ),
                ],
              ),
              drawer: const CustomDrawer(),
            ),
          ],
        )
    );
  }

  Future<void> editAds({AdClass? ad, required int tabIndex}) async{

    // Уходим на страницу создания / редактирования
    // Ждем результат с нее

    final results = await sm.pushToPageWithResult(
        context: context,
        page: AdViewCreateEditScreen(ad: ad, indexTabPage: tabIndex,)
    );

    if (results != null) {
      await initializationAndFilter(fromDb: false, slot: filterSlot.index, location: filterLocation.location, searchingText: searchingController.text);
    }

  }

}
