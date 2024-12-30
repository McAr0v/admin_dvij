import 'package:admin_dvij/constants/system_constants.dart';
import 'package:admin_dvij/promos/promo_class.dart';
import 'package:flutter/material.dart';
import '../design/app_colors.dart';
import '../design_elements/cards_elements.dart';

class PromosListScreen extends StatefulWidget {
  final List<Promo> promosList;
  final void Function(int index) editPromo;
  const PromosListScreen({required this.promosList, required this.editPromo,  Key? key}) : super(key: key);

  @override
  State<PromosListScreen> createState() => _PromosListScreenState();
}

class _PromosListScreenState extends State<PromosListScreen> {
  @override
  Widget build(BuildContext context) {
    if (widget.promosList.isNotEmpty) {

      return ListView.builder(
          padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
          itemCount: widget.promosList.length,
          itemBuilder: (context, index) {

            Promo tempPromo = widget.promosList[index];

            return CardsElements.getCard(
              context: context,
              onTap: () => widget.editPromo(index),
              imageUrl: tempPromo.imageUrl,
              leftTopTag: tempPromo.category.getCategoryWidget(context: context),
              leftBottomTag: tempPromo.inPlaceWidget(context: context),
              widget: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(tempPromo.headline),
                  const SizedBox(height: 10,),
                  Text(
                      tempPromo.desc,
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
                      tempPromo.getEventStatusWidget(context: context),
                      tempPromo.getFavCounterWidget(context: context),
                    ],
                  ),

                  const SizedBox(height: 10,),

                  Wrap(
                    alignment: WrapAlignment.start,
                    spacing: 10, // Горизонтальное расстояние между элементами
                    runSpacing: 10, // Вертикальное расстояние между строками
                    children: [

                      tempPromo.getDateTypeWidget(context: context),

                      tempPromo.getPromosDatesWidget(context: context),

                      tempPromo.getPromosTimeWidget(context: context)
                    ],
                  ),
                ],
              ),
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
