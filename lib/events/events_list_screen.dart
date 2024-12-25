import 'package:admin_dvij/design/loading_screen.dart';
import 'package:admin_dvij/events/event_class.dart';
import 'package:admin_dvij/events/events_list_class.dart';
import 'package:admin_dvij/navigation/drawer_custom.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../constants/screen_constants.dart';
import '../design/app_colors.dart';
import '../design_elements/cards_elements.dart';

class EventsListScreen extends StatefulWidget {
  const EventsListScreen({Key? key}) : super(key: key);

  @override
  State<EventsListScreen> createState() => _EventsListScreenState();
}

class _EventsListScreenState extends State<EventsListScreen> {
  
  EventsListClass eventsListClass = EventsListClass();
  
  bool loading = false;
  
  List <EventClass> eventsList = [];
  
  @override
  void initState() {
    initialization();
    super.initState();
  }
  
  Future<void> initialization({bool fromDb = false}) async {
    setState(() {
      loading = true;
    });

    
    eventsList = await eventsListClass.getDownloadedList(fromDb: fromDb);
    
    setState(() {
      loading = false;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text(ScreenConstants.events),
          /*actions: [

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

          ],*/

          /*bottom: PreferredSize(
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
          )*/
      ),
      drawer: const CustomDrawer(),
      body: Stack(
        children: [
          if (loading) const LoadingScreen()
          else if (eventsList.isNotEmpty) Column(
            children: [
              Expanded(
                child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                    itemCount: eventsList.length,
                    itemBuilder: (context, index) {

                      EventClass tempEvent = eventsList[index];

                      return CardsElements.getCard(
                          context: context,
                          onTap: () async {
                            /*final result = await sm.pushToPageWithResult(
                                context: context,
                                page: PlaceCreateViewEditScreen(place: tempEvent,)
                            );

                            if (result != null) {
                              await initialization(
                                  category: filterCategory,
                                  searchingText: searchingController.text,
                                  filterHaveEvents: filterHaveEvents,
                                  filterHavePromos: filterHavePromos
                              );
                            }*/

                          },
                          imageUrl: tempEvent.imageUrl,
                        leftTopTag: tempEvent.category.getCategoryWidget(context: context),
                        leftBottomTag: tempEvent.inPlaceWidget(context: context),
                          widget: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(tempEvent.headline),
                              const SizedBox(height: 10,),
                              Text(
                                  tempEvent.desc,
                                  style: Theme.of(context).textTheme.labelMedium!.copyWith(color: AppColors.greyText),
                                  softWrap: true,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis
                              ),

                              const SizedBox(height: 10,),

                              Wrap(
                                alignment: WrapAlignment.start,
                                spacing: 10, // Горизонтальное расстояние между элементами
                                runSpacing: 10, // Вертикальное расстояние между строками
                                children: [
                                  tempEvent.getEventStatusWidget(context: context),
                                  tempEvent.getFavCounter(context: context),
                                  tempEvent.getPriceWidget(context: context),

                                ],
                              ),

                              const SizedBox(height: 10,),

                              Wrap(
                                alignment: WrapAlignment.start,
                                spacing: 10, // Горизонтальное расстояние между элементами
                                runSpacing: 10, // Вертикальное расстояние между строками
                                children: [

                                  tempEvent.getDateTypeWidget(context: context),

                                  tempEvent.getEventsDatesWidget(context: context),

                                  tempEvent.getEventsTimeWidget(context: context)
                                ],
                              ),



                              /*Row(
                                  children: [
                                    
                                    tempEvent.getEventsCounter(context: context),
                                    tempEvent.getPromosCounter(context: context)
                                  ]
                              )*/
                            ],
                          ),
                          //leftTopTag: tempEvent.category.getCategoryWidget(context: context)
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
}
