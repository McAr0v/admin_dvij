import 'package:admin_dvij/constants/feedback_constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../design_elements/elements_of_design.dart';

enum FeedbackTopicEnum {
  bugReport,          // Сообщение о баге или ошибке в приложении
  featureRequest,     // Запрос на добавление новой функции
  uiUx,               // Вопросы, связанные с пользовательским интерфейсом и удобством использования
  performance,        // Вопросы, связанные с производительностью приложения
  accountIssues,      // Проблемы, связанные с учетной записью пользователя
  paymentIssues,      // Проблемы с оплатой или подпиской
  generalFeedback,    // Общие отзывы или предложения
  other,               // Другое
  notChosen               // Другое
}

class FeedbackTopic {

  FeedbackTopicEnum topic;

  FeedbackTopic({this.topic = FeedbackTopicEnum.notChosen});

  factory FeedbackTopic.fromString({required String topic}){
    switch (topic) {
      case FeedbackConstants.topicBugReport: return FeedbackTopic(topic: FeedbackTopicEnum.bugReport);
      case FeedbackConstants.topicFeatureRequest: return FeedbackTopic(topic: FeedbackTopicEnum.featureRequest);
      case FeedbackConstants.topicUiUx: return FeedbackTopic(topic: FeedbackTopicEnum.uiUx);
      case FeedbackConstants.topicPerformance: return FeedbackTopic(topic: FeedbackTopicEnum.performance);
      case FeedbackConstants.topicAccountIssues: return FeedbackTopic(topic: FeedbackTopicEnum.accountIssues);
      case FeedbackConstants.topicPaymentIssues: return FeedbackTopic(topic: FeedbackTopicEnum.paymentIssues);
      case FeedbackConstants.topicGeneralFeedback: return FeedbackTopic(topic: FeedbackTopicEnum.generalFeedback);
      case FeedbackConstants.topicOther: return FeedbackTopic(topic: FeedbackTopicEnum.other);

      default: return FeedbackTopic(topic: FeedbackTopicEnum.notChosen);
    }
  }

  @override
  String toString({bool translate = false}) {
    switch (topic) {
      case FeedbackTopicEnum.bugReport: return !translate ? FeedbackConstants.topicBugReport : FeedbackConstants.topicBugReportTranslateText;
      case FeedbackTopicEnum.featureRequest: return !translate ? FeedbackConstants.topicFeatureRequest : FeedbackConstants.topicFeatureRequestTranslateText;
      case FeedbackTopicEnum.uiUx: return !translate ? FeedbackConstants.topicUiUx : FeedbackConstants.topicUiUxTranslateText;
      case FeedbackTopicEnum.performance: return !translate ? FeedbackConstants.topicPerformance : FeedbackConstants.topicPerformanceTranslateText;
      case FeedbackTopicEnum.accountIssues: return !translate ? FeedbackConstants.topicAccountIssues : FeedbackConstants.topicAccountIssuesTranslateText;
      case FeedbackTopicEnum.paymentIssues: return !translate ? FeedbackConstants.topicPaymentIssues : FeedbackConstants.topicPaymentIssuesTranslateText;
      case FeedbackTopicEnum.generalFeedback: return !translate ? FeedbackConstants.topicGeneralFeedback : FeedbackConstants.topicGeneralFeedbackTranslateText;
      case FeedbackTopicEnum.other: return !translate ? FeedbackConstants.topicOther : FeedbackConstants.topicOtherTranslateText;
      case FeedbackTopicEnum.notChosen: return !translate ? FeedbackConstants.topicNotChosen : FeedbackConstants.topicNotChosenTranslateText;
    }
  }

  List<FeedbackTopic> getTopicsList(){
    return [
      FeedbackTopic(topic: FeedbackTopicEnum.bugReport),
      FeedbackTopic(topic: FeedbackTopicEnum.featureRequest),
      FeedbackTopic(topic: FeedbackTopicEnum.uiUx),
      FeedbackTopic(topic: FeedbackTopicEnum.performance),
      FeedbackTopic(topic: FeedbackTopicEnum.accountIssues),
      FeedbackTopic(topic: FeedbackTopicEnum.paymentIssues),
      FeedbackTopic(topic: FeedbackTopicEnum.generalFeedback),
      FeedbackTopic(topic: FeedbackTopicEnum.other),
    ];
  }

  Widget getTopicFieldWidget({
    required bool canEdit,
    required BuildContext context,
    required VoidCallback onTap
  }){

    TextEditingController textController = TextEditingController();
    textController.text = toString(translate: true);

    return ElementsOfDesign.buildTextField(
        controller: textController,
        labelText:  FeedbackConstants.topicHeadline,
        canEdit: canEdit,
        icon: FontAwesomeIcons.tag,
        context: context,
        readOnly: true,
        onTap: onTap
    );
  }

}