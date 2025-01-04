import 'package:admin_dvij/privacy_policy/privacy_enum.dart';
import 'package:flutter/material.dart';
import '../../design/app_colors.dart';

class PrivacyStatusPicker extends StatefulWidget {

  const PrivacyStatusPicker({super.key});

  @override
  State<PrivacyStatusPicker> createState() => _PrivacyStatusPickerState();
}

class _PrivacyStatusPickerState extends State<PrivacyStatusPicker> {

  List<PrivacyStatus> privacyStatusList = [
    PrivacyStatus(privacyEnum: PrivacyEnum.draft),
    PrivacyStatus(privacyEnum: PrivacyEnum.active)
  ];

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
            children: privacyStatusList.map((PrivacyStatus status) {
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