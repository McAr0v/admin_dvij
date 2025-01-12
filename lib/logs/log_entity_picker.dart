import 'package:admin_dvij/logs/entity_enum.dart';
import 'package:flutter/material.dart';
import '../../design/app_colors.dart';

class LogEntityPicker extends StatefulWidget {

  const LogEntityPicker({super.key});

  @override
  State<LogEntityPicker> createState() => _LogEntityPickerState();
}

class _LogEntityPickerState extends State<LogEntityPicker> {

  List<LogEntity> list = LogEntity(entity: EntityEnum.notChosen).getEntitiesList();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      decoration: const BoxDecoration(
        color: AppColors.greyBackground,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
      ),
      child: SingleChildScrollView(
          child: ListBody(
            children: list.map((LogEntity entity) {
              return GestureDetector(
                onTap: () {
                  Navigator.of(context).pop(entity);
                },
                child: Card(
                  color: AppColors.greyOnBackground,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                      entity.toString(translate: true),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ),
              );
            }).toList(),
          )
      ),
    );
  }
}