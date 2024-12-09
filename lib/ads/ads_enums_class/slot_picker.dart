import 'package:admin_dvij/ads/ads_enums_class/ad_index.dart';
import 'package:flutter/material.dart';
import '../../design/app_colors.dart';

class SlotPicker extends StatefulWidget {
  const SlotPicker({Key? key}) : super(key: key);

  @override
  State<SlotPicker> createState() => _SlotPickerState();
}

class _SlotPickerState extends State<SlotPicker> {
  List<AdIndex> indexList = [];

  @override
  void initState() {
    super.initState();
    AdIndex tempIndex = AdIndex(index: AdIndexEnum.notChosen);
    indexList = tempIndex.getIndexList();
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
            children: indexList.map((AdIndex index) {
              return GestureDetector(
                onTap: () {
                  Navigator.of(context).pop(index);
                },
                child: Card(
                  color: AppColors.greyOnBackground,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                      index.toString(translate: true),
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
