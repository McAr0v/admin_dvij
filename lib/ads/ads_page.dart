import 'package:admin_dvij/ads/ad_class.dart';
import 'package:admin_dvij/ads/ad_view_create_edit_screen.dart';
import 'package:admin_dvij/ads/ads_enums_class/ad_index.dart';
import 'package:admin_dvij/ads/ads_enums_class/ad_location.dart';
import 'package:admin_dvij/ads/ads_enums_class/ad_status.dart';
import 'package:admin_dvij/ads/ads_list_class.dart';
import 'package:admin_dvij/ads/ads_list_screen.dart';
import 'package:admin_dvij/ads/filter_picker.dart';
import 'package:admin_dvij/constants/ads_constants.dart';
import 'package:admin_dvij/constants/buttons_constants.dart';
import 'package:admin_dvij/design/loading_screen.dart';
import 'package:admin_dvij/design_elements/elements_of_design.dart';
import 'package:admin_dvij/navigation/drawer_custom.dart';
import 'package:admin_dvij/system_methods/system_methods_class.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../constants/screen_constants.dart';
import '../design/app_colors.dart';

class AdsPage extends StatefulWidget {
  final int initialIndex;
  const AdsPage({this.initialIndex = 0, Key? key}) : super(key: key);

  @override
  State<AdsPage> createState() => _AdsPageState();
}

class _AdsPageState extends State<AdsPage> {

  SystemMethodsClass sm = SystemMethodsClass();

  bool loading = false;



  AdsList adsList = AdsList();
  List<AdClass> activeAdsList = [];
  List<AdClass> draftAdsList = [];
  List<AdClass> completedAdsList = [];

  // Переменные фильтра
  AdIndex filterSlot = AdIndex(index: AdIndexEnum.notChosen);
  AdLocation filterLocation = AdLocation(location: AdLocationEnum.notChosen);
  TextEditingController searchingController = TextEditingController();

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

  Future<void> createAd() async{

    final result = await sm.pushToPageWithResult(context: context, page: const AdViewCreateEditScreen(indexTabPage: 0));

    if (result != null){
      await initializationAndFilter(fromDb: false, slot: filterSlot.index, location: filterLocation.location, searchingText: searchingController.text );
    }

  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: widget.initialIndex,
        length: 3,
        child: Stack(
          children: [
            if (loading) const LoadingScreen(loadingText: AdsConstants.loadingAdProcess,),
            if (!loading) Scaffold(
              appBar: AppBar(
                title: const Text(ScreenConstants.adsPage),
                actions: [

                  // КНОПКИ В AppBar

                  Row(
                    children: [

                      // Кнопка сброса фильтра

                      if (filterLocation.location != AdLocationEnum.notChosen || filterSlot.index != AdIndexEnum.notChosen)
                        ElementsOfDesign.linkButton(
                            method: () async {
                              await resetFilter();
                            },
                            text: ButtonsConstants.reset,
                            context: context
                        ),

                      if (filterLocation.location != AdLocationEnum.notChosen || filterSlot.index != AdIndexEnum.notChosen)
                        const SizedBox(width: 10,),

                      // Кнопка "Фильтр"

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
                      await createAd();
                    },
                    icon: const Icon(FontAwesomeIcons.plus, size: 15, color: AppColors.white,),
                  ),

                ],

                // ТАБЫ

                bottom: TabBar(
                  tabs: [
                    ElementsOfDesign.getTabWithIcon(icon: FontAwesomeIcons.fire, text: AdsConstants.activeTab),
                    ElementsOfDesign.getTabWithIcon(icon: FontAwesomeIcons.fileLines, text: AdsConstants.draftTab),
                    ElementsOfDesign.getTabWithIcon(icon: FontAwesomeIcons.circleCheck, text: AdsConstants.completedTab),
                  ],
                ),
              ),

              // СОДЕРЖИМОЕ СТРАНИЦЫ

              body: Column(
                children: [
                  ElementsOfDesign.getSearchBar(
                      context: context,
                      textController: searchingController,
                      labelText: AdsConstants.searchBarHeadline,
                      icon: FontAwesomeIcons.searchengin,
                      onChanged: (value) async {
                        await searchingAction(text: value);
                      },
                      onClean: () async{
                        await searchingAction(text: '');
                      }
                  ),
                  Expanded(
                    child: TabBarView(
                        children: [

                          AdsListScreen(
                              adsList: activeAdsList,
                              editAds: (index) async {
                                await editAds(ad: activeAdsList[index], tabIndex: 0);
                              },
                          ),

                          AdsListScreen(
                            adsList: draftAdsList,
                            editAds: (index) async {
                              await editAds(ad: draftAdsList[index], tabIndex: 1);
                            },
                          ),

                          AdsListScreen(
                            adsList: completedAdsList,
                            editAds: (index) async {
                              await editAds(ad: completedAdsList[index], tabIndex: 2);
                            },
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

  Future<void> searchingAction({required String text}) async {

    await initializationAndFilter(
      fromDb: false,
      location: filterLocation.location,
      slot: filterSlot.index,
      searchingText: searchingController.text,
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
