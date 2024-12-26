import 'package:flutter/material.dart';
import '../design/app_colors.dart';
import 'date_type.dart';

class DateTypePicker extends StatefulWidget {
  const DateTypePicker({Key? key}) : super(key: key);

  @override
  State<DateTypePicker> createState() => _DateTypePickerState();
}

class _DateTypePickerState extends State<DateTypePicker> {

  List<DateType> list = [];

  DateType type = DateType();

  @override
  void initState() {
    list = type.getTypesList();
    super.initState();
  }

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
            children: list.map((DateType type) {
              return GestureDetector(
                onTap: () {
                  Navigator.of(context).pop(type);
                },
                child: Card(
                  color: AppColors.greyOnBackground,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                      type.toString(translate: true),
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
