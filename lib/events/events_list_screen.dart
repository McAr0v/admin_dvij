import 'package:admin_dvij/constants/system_constants.dart';
import 'package:admin_dvij/events/event_class.dart';
import 'package:flutter/material.dart';
import '../design/app_colors.dart';
import '../design_elements/cards_elements.dart';

class EventsListScreen extends StatefulWidget {
  final List<EventClass> eventsList;
  final void Function(int index) editEvent;
  const EventsListScreen({required this.eventsList, required this.editEvent,  Key? key}) : super(key: key);

  @override
  State<EventsListScreen> createState() => _EventsListScreenState();
}

class _EventsListScreenState extends State<EventsListScreen> {
  @override
  Widget build(BuildContext context) {
    if (widget.eventsList.isNotEmpty) {

      return ListView.builder(
          padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
          itemCount: widget.eventsList.length,
          itemBuilder: (context, index) {

            EventClass tempEvent = widget.eventsList[index];

            return CardsElements.getCard(
              context: context,
              onTap: () => widget.editEvent(index),
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
      );
    } else {
      return Center(
        child: Text(SystemConstants.emptyList, style: Theme.of(context).textTheme.bodyMedium,),
      );
    }
  }
}
