import 'package:admin_dvij/ads/ads_enums_class/ad_status.dart';
import 'package:flutter/material.dart';
import '../../design/app_colors.dart';

class StatusPicker extends StatefulWidget {
  const StatusPicker({super.key});

  @override
  State<StatusPicker> createState() => _StatusPickerState();
}

class _StatusPickerState extends State<StatusPicker> {
  List<AdStatus> statusList = [];

  @override
  void initState() {
    super.initState();
    AdStatus tempStatus = AdStatus(status: AdStatusEnum.draft);
    statusList = tempStatus.getStatusList();
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
            children: statusList.map((AdStatus status) {
              return GestureDetector(
                onTap: () {
                  Navigator.of(context).pop(status);
                },
                child: Card(
                  color: AppColors.greyOnBackground,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                      status.toString(translate: true),
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
