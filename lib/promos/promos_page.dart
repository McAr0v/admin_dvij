import 'package:admin_dvij/categories/promo_categories/promo_category.dart';
import 'package:admin_dvij/cities/city_class.dart';
import 'package:admin_dvij/constants/events_constants.dart';
import 'package:admin_dvij/constants/promo_constants.dart';
import 'package:admin_dvij/design/loading_screen.dart';
import 'package:admin_dvij/navigation/drawer_custom.dart';
import 'package:admin_dvij/promos/filter_promos.dart';
import 'package:admin_dvij/promos/promo_class.dart';
import 'package:admin_dvij/promos/promo_create_edit_view_screen.dart';
import 'package:admin_dvij/promos/promos_list_class.dart';
import 'package:admin_dvij/promos/promos_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../constants/buttons_constants.dart';
import '../constants/screen_constants.dart';
import '../design/app_colors.dart';
import '../design_elements/elements_of_design.dart';
import '../system_methods/system_methods_class.dart';

class PromosPage extends StatefulWidget {
  final int initialIndex;
  const PromosPage({this.initialIndex = 0, Key? key}) : super(key: key);

  @override
  State<PromosPage> createState() => _PromosPageState();
}

class _PromosPageState extends State<PromosPage> {

  SystemMethodsClass sm = SystemMethodsClass();
  PromosListClass promosListClass = PromosListClass();

  bool loading = false;

  List <Promo> activePromosList = [];
  List <Promo> completedPromosList = [];

  TextEditingController searchingController = TextEditingController();

  City filterCity = City.empty();
  PromoCategory filterCategory = PromoCategory.empty();
  bool filterInPlace = false;


  @override
  void initState() {
    initialization();
    super.initState();
  }

  Future<void> initialization({bool fromDb = false}) async {
    setState(() {
      loading = true;
    });

    activePromosList = await promosListClass.getNeededPromos(
        filterCity: filterCity,
        filterCategory: filterCategory,
        filterInPlace: filterInPlace,
        searchingText: searchingController.text,
        isActive: true,
        fromDb: fromDb
    );

    completedPromosList = await promosListClass.getNeededPromos(
        filterCity: filterCity,
        filterCategory: filterCategory,
        filterInPlace: filterInPlace,
        searchingText: searchingController.text,
        isActive: false,
        fromDb: fromDb
    );

    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        initialIndex: widget.initialIndex,
        length: 2,
        child: Stack(
          children: [
            if (loading) const LoadingScreen(loadingText: PromoConstants.loadingPromoProcess,),
            if (!loading) Scaffold(
              appBar: AppBar(
                title: const Text(ScreenConstants.promos),
                actions: [

                  // КНОПКИ В AppBar

                  Row(
                    children: [

                      // Кнопка сброса фильтра

                      if (filterInPlace || filterCategory.id.isNotEmpty || filterCity.name.isNotEmpty)
                        ElementsOfDesign.linkButton(
                            method: () async {
                              await resetFilter();
                            },
                            text: ButtonsConstants.reset,
                            context: context
                        ),

                      if (filterInPlace || filterCategory.id.isNotEmpty || filterCity.name.isNotEmpty)
                        const SizedBox(width: 10,),

                      // Кнопка "Фильтр"

                      IconButton(
                        onPressed: () async {
                          await filterPromos();
                        },
                        icon: Icon(
                          FontAwesomeIcons.filter,
                          size: 15,
                          color: filterInPlace || filterCategory.id.isNotEmpty || filterCity.name.isNotEmpty ? AppColors.brandColor : AppColors.white,),
                      ),
                    ],
                  ),

                  // Кнопка "Обновить"

                  IconButton(
                    onPressed: () async {
                      await initialization(fromDb: true);
                    },
                    icon: const Icon(FontAwesomeIcons.arrowsRotate, size: 15, color: AppColors.white,),
                  ),

                  // Кнопка "Создать"

                  IconButton(
                    onPressed: () async {
                      await editPromos(tabIndex: 0);
                    },
                    icon: const Icon(FontAwesomeIcons.plus, size: 15, color: AppColors.white,),
                  ),

                ],

                // ТАБЫ

                bottom: TabBar(
                  tabs: [
                    ElementsOfDesign.getTabWithIcon(icon: FontAwesomeIcons.fire, text: EventsConstants.activeTab),
                    ElementsOfDesign.getTabWithIcon(icon: FontAwesomeIcons.fileLines, text: EventsConstants.completedTab),
                  ],
                ),
              ),

              // СОДЕРЖИМОЕ СТРАНИЦЫ

              body: Column(
                children: [
                  ElementsOfDesign.getSearchBar(
                      context: context,
                      textController: searchingController,
                      labelText: EventsConstants.searchBarHeadline,
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

                          PromosListScreen(
                            promosList: activePromosList,
                            editPromo: (index) async {
                              await editPromos(promo: activePromosList[index], tabIndex: 0);
                            },
                          ),

                          PromosListScreen(
                            promosList: completedPromosList,
                            editPromo: (index) async {
                              await editPromos(promo: completedPromosList[index], tabIndex: 1);
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
    searchingController.text = text;

    await initialization(
        fromDb: false
    );
  }

  Future<void> resetFilter() async{

    filterInPlace = false;
    filterCategory = PromoCategory.empty();
    filterCity = City.empty();
    searchingController.text = '';

    await initialization(fromDb: false);
  }

  Future<void> filterPromos() async{

    final result = await sm.getPopup(
        context: context,
        page: FilterPromos(
            inPlace: filterInPlace,
            filterCity: filterCity,
            filterCategory: filterCategory
        )
    );

    if (result != null){
      filterCity = result[0];
      filterCategory = result[1];
      filterInPlace = result[2];

      await initialization(fromDb: false);

    }
  }

  Future<void> editPromos({Promo? promo, required int tabIndex}) async{

    // Уходим на страницу создания / редактирования
    // Ждем результат с нее

    final results = await sm.pushToPageWithResult(
        context: context,
        page: PromoCreateViewEditScreen(promo: promo, indexTabPage: tabIndex,)
    );

    if (results != null) {
      await initialization();
    }

  }

}
