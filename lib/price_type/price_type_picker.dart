import 'package:admin_dvij/price_type/price_type_class.dart';
import 'package:flutter/material.dart';
import '../design/app_colors.dart';

class PriceTypePicker extends StatefulWidget {
  const PriceTypePicker({Key? key}) : super(key: key);

  @override
  State<PriceTypePicker> createState() => _PriceTypePickerState();
}

class _PriceTypePickerState extends State<PriceTypePicker> {

  PriceType priceType = PriceType();

  List<PriceType> typesList = [];

  @override
  void initState() {
    typesList = priceType.getPriceTypesList();
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
            children: typesList.map((PriceType priceType) {
              return GestureDetector(
                onTap: () {
                  Navigator.of(context).pop(priceType);
                },
                child: Card(
                  color: AppColors.greyOnBackground,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                      priceType.toString(translate: true),
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
