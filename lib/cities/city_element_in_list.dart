import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../design/app_colors.dart';
import 'city_class.dart';

class CityElementInList extends StatelessWidget {
  final City city;
  final VoidCallback onDelete;
  final VoidCallback onEdit;


  const CityElementInList({required this.city, required this.onEdit, required this.onDelete, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.greyOnBackground,
      //padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
        child: Row(
          children: [

            IconButton(
              onPressed: onEdit,
              icon: const Icon(FontAwesomeIcons.penToSquare, size: 15, color: AppColors.brandColor),
            ),

            const SizedBox(width: 20,),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(city.name, style: Theme.of(context).textTheme.bodyMedium,),
                  const SizedBox(width: 20,),
                  Text(city.id, style: Theme.of(context).textTheme.labelSmall,),

                ],
              ),
            ),

            IconButton(
              onPressed: onDelete,
              icon: const Icon(FontAwesomeIcons.trash, size: 15, color: AppColors.attentionRed,),
            ),

          ],
        ),
      ),
    );
  }
}
