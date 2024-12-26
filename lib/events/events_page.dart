import 'package:admin_dvij/categories/event_categories/event_category.dart';
import 'package:admin_dvij/cities/city_class.dart';
import 'package:admin_dvij/constants/events_constants.dart';
import 'package:admin_dvij/design/loading_screen.dart';
import 'package:admin_dvij/events/event_class.dart';
import 'package:admin_dvij/events/event_create_view_edit_screen.dart';
import 'package:admin_dvij/events/events_list_class.dart';
import 'package:admin_dvij/events/events_list_screen.dart';
import 'package:admin_dvij/events/filter_events.dart';
import 'package:admin_dvij/navigation/drawer_custom.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../constants/buttons_constants.dart';
import '../constants/screen_constants.dart';
import '../design/app_colors.dart';
import '../design_elements/elements_of_design.dart';
import '../system_methods/system_methods_class.dart';

class EventsPage extends StatefulWidget {
  final int initialIndex;
  const EventsPage({this.initialIndex = 0, Key? key}) : super(key: key);

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {

  SystemMethodsClass sm = SystemMethodsClass();
  EventsListClass eventsListClass = EventsListClass();

  bool loading = false;

  List <EventClass> activeEventsList = [];
  List <EventClass> completedEventsList = [];

  TextEditingController searchingController = TextEditingController();

  City filterCity = City.empty();
  EventCategory filterCategory = EventCategory.empty();
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

    activeEventsList = await eventsListClass.getNeededEvents(
        filterCity: filterCity,
        filterCategory: filterCategory,
        filterInPlace: filterInPlace,
        searchingText: searchingController.text,
        isActive: true
    );

    completedEventsList = await eventsListClass.getNeededEvents(
        filterCity: filterCity,
        filterCategory: filterCategory,
        filterInPlace: filterInPlace,
        searchingText: searchingController.text,
        isActive: false
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
            if (loading) const LoadingScreen(loadingText: EventsConstants.loadingEventProcess,),
            if (!loading) Scaffold(
              appBar: AppBar(
                title: const Text(ScreenConstants.events),
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
                          await filterEvents();
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
                      await editEvents(tabIndex: 0);
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

                          EventsListScreen(
                              eventsList: activeEventsList,
                              editEvent: (index) async {
                                await editEvents(event: activeEventsList[index], tabIndex: 0);
                              },
                          ),

                          EventsListScreen(
                            eventsList: completedEventsList,
                            editEvent: (index) async {
                              await editEvents(event: completedEventsList[index], tabIndex: 1);
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
    filterCategory = EventCategory.empty();
    filterCity = City.empty();
    searchingController.text = '';

    await initialization(fromDb: false);
  }

  Future<void> filterEvents() async{

    final result = await sm.getPopup(
        context: context,
        page: FilterEvents(
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

  Future<void> editEvents({EventClass? event, required int tabIndex}) async{

    // Уходим на страницу создания / редактирования
    // Ждем результат с нее

    final results = await sm.pushToPageWithResult(
        context: context,
        page: EventCreateViewEditScreen(event: event, indexTabPage: tabIndex,)
    );

    if (results != null) {
      await initialization();
    }

  }

}
