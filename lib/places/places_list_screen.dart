import 'package:admin_dvij/categories/place_categories/place_category.dart';
import 'package:admin_dvij/constants/places_constants.dart';
import 'package:admin_dvij/constants/screen_constants.dart';
import 'package:admin_dvij/design/loading_screen.dart';
import 'package:admin_dvij/navigation/drawer_custom.dart';
import 'package:admin_dvij/places/place_class.dart';
import 'package:admin_dvij/places/place_create_view_edit_screen.dart';
import 'package:admin_dvij/places/place_filter_picker.dart';
import 'package:admin_dvij/places/places_list_class.dart';
import 'package:admin_dvij/system_methods/system_methods_class.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../constants/buttons_constants.dart';
import '../design/app_colors.dart';
import '../design_elements/cards_elements.dart';
import '../design_elements/elements_of_design.dart';

class PlacesListScreen extends StatefulWidget {
  const PlacesListScreen({Key? key}) : super(key: key);

  @override
  State<PlacesListScreen> createState() => _PlacesListScreenState();
}

class _PlacesListScreenState extends State<PlacesListScreen> {

  SystemMethodsClass sm = SystemMethodsClass();
  PlacesList placesListManager = PlacesList();
  bool loading = false;

  PlaceCategory filterCategory = PlaceCategory.empty();
  bool filterHaveEvents = false;
  bool filterHavePromos = false;

  List<Place> placesList = [];

  TextEditingController searchingController = TextEditingController();

  @override
  void initState() {
    initialization(category: filterCategory, filterHavePromos: filterHavePromos, filterHaveEvents: filterHaveEvents);
    super.initState();
  }

  Future<void> initialization({
    bool fromDb = false,
    required PlaceCategory category,
    required bool filterHaveEvents,
    required bool filterHavePromos,
    String searchingText = ''
  }) async {
    setState(() {
      loading = true;
    });

    placesList = await placesListManager.getNeededPlaces(
        category: filterCategory,
        searchingText: searchingController.text,
        fromDb: fromDb,
        filterHaveEvents: filterHaveEvents,
        filterHavePromos: filterHavePromos
    );

    setState(() {
      loading = false;
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(ScreenConstants.places),
        actions: [

          // КНОПКИ В AppBar

          Row(
            children: [

              // Кнопка сброса фильтра

              if (filterHavePromos || filterHaveEvents || filterCategory.id.isNotEmpty)
                ElementsOfDesign.linkButton(
                    method: () async {
                      await resetFilter();
                    },
                    text: ButtonsConstants.reset,
                    context: context
                ),

              if (filterHavePromos || filterHaveEvents || filterCategory.id.isNotEmpty)
                const SizedBox(width: 10,),

              // Кнопка "Фильтр"

              IconButton(
                onPressed: () async {
                  await filterPlaces();
                },
                icon: Icon(
                  FontAwesomeIcons.filter,
                  size: 15,
                  color: filterHavePromos || filterHaveEvents || filterCategory.id.isNotEmpty ? AppColors.brandColor : AppColors.white,),
              ),
            ],
          ),

          // Кнопка "Обновить"

          IconButton(
            onPressed: () async {
              await initialization(
                  fromDb: true,
                  searchingText: searchingController.text,
                  category: filterCategory,
                  filterHaveEvents: filterHaveEvents,
                  filterHavePromos: filterHavePromos
              );
            },
            icon: const Icon(FontAwesomeIcons.arrowsRotate, size: 15, color: AppColors.white,),
          ),

          // Кнопка "Создать"

          IconButton(
            onPressed: () async {
              final result = await sm.pushToPageWithResult(
                  context: context,
                  page: const PlaceCreateViewEditScreen()
              );

              if (result != null) {
                await initialization(
                    category: filterCategory,
                    searchingText: searchingController.text,
                  filterHavePromos: filterHavePromos,
                  filterHaveEvents: filterHaveEvents
                );
              }

            },
            icon: const Icon(FontAwesomeIcons.plus, size: 15, color: AppColors.white,),
          ),

        ],

        bottom: PreferredSize(
            preferredSize: const Size.fromHeight(70),
            child: ElementsOfDesign.getSearchBar(
                context: context,
                textController: searchingController,
                labelText: PlacesConstants.searchBarHeadline,
                icon: FontAwesomeIcons.searchengin,
                onChanged: (value) async {
                  await searchingAction(text: value);
                },
                onClean: () async{
                  await searchingAction(text: '');
                }
            ),
        )

      ),
      drawer: const CustomDrawer(),
      body: Stack(
        children: [
          if (loading) const LoadingScreen()
          else if (placesList.isNotEmpty) Column(
            children: [


              Expanded(
                child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                    itemCount: placesList.length,
                    itemBuilder: (context, index) {

                      Place tempPlace = placesList[index];

                      return CardsElements.getCard(
                          context: context,
                          onTap: () async {
                            final result = await sm.pushToPageWithResult(
                              context: context,
                              page: PlaceCreateViewEditScreen(place: tempPlace,)
                            );

                            if (result != null) {
                              await initialization(
                                  category: filterCategory,
                                  searchingText: searchingController.text,
                                filterHaveEvents: filterHaveEvents,
                                filterHavePromos: filterHavePromos
                              );
                            }

                          },//() => widget.editAds(index), // Передаем index через замыкание
                          imageUrl: tempPlace.imageUrl,
                          widget: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(tempPlace.name),
                              Text(tempPlace.getAddress(), style: Theme.of(context).textTheme.labelMedium!.copyWith(color: AppColors.greyText),),
                              const SizedBox(height: 10,),
                              Text(
                                  tempPlace.desc,
                                  style: Theme.of(context).textTheme.labelMedium!.copyWith(color: AppColors.greyText),
                                  softWrap: true,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis
                              ),

                              const SizedBox(height: 10,),

                              Row(
                                children: [
                                  tempPlace.getFavCounter(context: context),
                                  tempPlace.getEventsCounter(context: context),
                                  tempPlace.getPromosCounter(context: context)
                                ]
                              )
                            ],
                          ),
                          leftTopTag: tempPlace.category.getCategoryWidget(context: context)
                      );

                    }
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Future<void> filterPlaces() async{

    final result = await sm.getPopup(
        context: context,
        page: PlaceFilterPicker(placeCategory: filterCategory, havePromos: filterHavePromos, haveEvents: filterHaveEvents)
    );

    if (result != null){
      filterCategory = result[0];
      filterHaveEvents = result[1];
      filterHavePromos = result[2];

      await initialization(
          category: filterCategory,
          searchingText: searchingController.text,
          filterHavePromos: filterHavePromos,
          filterHaveEvents: filterHaveEvents
      );
    }

  }

  Future<void> resetFilter() async{
    filterCategory = PlaceCategory.empty();
    filterHaveEvents = false;
    filterHavePromos = false;
    searchingController.text = '';

    await initialization(
        category: filterCategory,
        filterHaveEvents: filterHaveEvents,
        filterHavePromos: filterHavePromos,
        searchingText: searchingController.text
    );
  }

  Future<void> searchingAction({required String text}) async {

    await initialization(
      fromDb: false,
      category: filterCategory,
      searchingText: searchingController.text,
      filterHaveEvents: filterHaveEvents,
      filterHavePromos: filterHavePromos
    );
  }

}
