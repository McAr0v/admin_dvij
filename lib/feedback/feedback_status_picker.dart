import 'package:flutter/material.dart';
import '../../design/app_colors.dart';
import 'feedback_status.dart';

class FeedbackStatusPicker extends StatefulWidget {

  const FeedbackStatusPicker({super.key});

  @override
  State<FeedbackStatusPicker> createState() => _FeedbackStatusPickerState();
}

class _FeedbackStatusPickerState extends State<FeedbackStatusPicker> {

  List<FeedbackStatus> statusList = [];

  @override
  void initState() {
    super.initState();
    statusList = FeedbackStatus().getStatusList();
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
            children: statusList.map((FeedbackStatus status) {
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