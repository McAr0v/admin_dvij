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
      case 'bugReport': return FeedbackTopic(topic: FeedbackTopicEnum.bugReport);
      case 'featureRequest': return FeedbackTopic(topic: FeedbackTopicEnum.featureRequest);
      case 'uiUx': return FeedbackTopic(topic: FeedbackTopicEnum.uiUx);
      case 'performance': return FeedbackTopic(topic: FeedbackTopicEnum.performance);
      case 'accountIssues': return FeedbackTopic(topic: FeedbackTopicEnum.accountIssues);
      case 'paymentIssues': return FeedbackTopic(topic: FeedbackTopicEnum.paymentIssues);
      case 'generalFeedback': return FeedbackTopic(topic: FeedbackTopicEnum.generalFeedback);
      case 'other': return FeedbackTopic(topic: FeedbackTopicEnum.other);

      default: return FeedbackTopic(topic: FeedbackTopicEnum.notChosen);
    }
  }

  @override
  String toString({bool translate = false}) {
    switch (topic) {
      case FeedbackTopicEnum.bugReport: return !translate ? 'bugReport' : 'Сообщение о баге или ошибке в приложении';
      case FeedbackTopicEnum.featureRequest: return !translate ? 'featureRequest' : 'Запрос на добавление новой функции';
      case FeedbackTopicEnum.uiUx: return !translate ? 'uiUx' : 'Вопросы, связанные с пользовательским интерфейсом и удобством использования';
      case FeedbackTopicEnum.performance: return !translate ? 'performance' : 'Вопросы, связанные с производительностью приложения';
      case FeedbackTopicEnum.accountIssues: return !translate ? 'accountIssues' : 'Проблемы, связанные с учетной записью пользователя';
      case FeedbackTopicEnum.paymentIssues: return !translate ? 'paymentIssues' : 'Проблемы с оплатой или подпиской';
      case FeedbackTopicEnum.generalFeedback: return !translate ? 'generalFeedback' : 'Общие отзывы или предложения';
      case FeedbackTopicEnum.other: return !translate ? 'other' : 'Другое';
      case FeedbackTopicEnum.notChosen: return !translate ? 'notChosen' : 'Не выбрано';
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
        labelText: 'Тема обращения',
        canEdit: canEdit,
        icon: FontAwesomeIcons.mapLocation,
        context: context,
        readOnly: true,
        onTap: onTap
    );
  }

}