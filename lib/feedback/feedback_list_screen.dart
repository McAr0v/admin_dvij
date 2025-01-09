import 'package:admin_dvij/feedback/feedback_class.dart';
import 'package:flutter/material.dart';
import '../constants/system_constants.dart';

class FeedbackListScreen extends StatefulWidget {
  final List<FeedbackCustom> feedbackList;
  final void Function(int index) onTapFeedback;
  const FeedbackListScreen({required this.feedbackList, required this.onTapFeedback, Key? key}) : super(key: key);

  @override
  State<FeedbackListScreen> createState() => _FeedbackListScreenState();
}

class _FeedbackListScreenState extends State<FeedbackListScreen> {

  @override
  Widget build(BuildContext context) {
    if (widget.feedbackList.isNotEmpty) {

      return ListView.builder(
          padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
          itemCount: widget.feedbackList.length,
          itemBuilder: (context, index) {

            FeedbackCustom feedback = widget.feedbackList[index];

            return feedback.getFeedbackWidget(
                context: context,
              onTap: () => widget.onTapFeedback(index)
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
