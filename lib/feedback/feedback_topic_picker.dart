import 'package:flutter/material.dart';
import '../../design/app_colors.dart';
import 'feedback_topic.dart';

class FeedbackTopicPicker extends StatefulWidget {

  const FeedbackTopicPicker({super.key});

  @override
  State<FeedbackTopicPicker> createState() => _FeedbackTopicPickerState();
}

class _FeedbackTopicPickerState extends State<FeedbackTopicPicker> {

  List<FeedbackTopic> topicList = [];

  @override
  void initState() {
    super.initState();
    topicList = FeedbackTopic().getTopicsList();
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
            children: topicList.map((FeedbackTopic topic) {
              return GestureDetector(
                onTap: () {
                  Navigator.of(context).pop(topic);
                },
                child: Card(
                  color: AppColors.greyOnBackground,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                      topic.toString(translate: true),
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