enum FeedbackTopicEnum {
  bugReport,          // Сообщение о баге или ошибке в приложении
  featureRequest,     // Запрос на добавление новой функции
  uiUx,               // Вопросы, связанные с пользовательским интерфейсом и удобством использования
  performance,        // Вопросы, связанные с производительностью приложения
  accountIssues,      // Проблемы, связанные с учетной записью пользователя
  paymentIssues,      // Проблемы с оплатой или подпиской
  generalFeedback,    // Общие отзывы или предложения
  other               // Другое
}

class FeedbackTopic {

  FeedbackTopicEnum topic;

  FeedbackTopic({this.topic = FeedbackTopicEnum.other});

  factory FeedbackTopic.fromString({required String topic}){
    switch (topic) {
      case 'bugReport': return FeedbackTopic(topic: FeedbackTopicEnum.bugReport);
      case 'featureRequest': return FeedbackTopic(topic: FeedbackTopicEnum.featureRequest);
      case 'uiUx': return FeedbackTopic(topic: FeedbackTopicEnum.uiUx);
      case 'performance': return FeedbackTopic(topic: FeedbackTopicEnum.performance);
      case 'accountIssues': return FeedbackTopic(topic: FeedbackTopicEnum.accountIssues);
      case 'paymentIssues': return FeedbackTopic(topic: FeedbackTopicEnum.paymentIssues);
      case 'generalFeedback': return FeedbackTopic(topic: FeedbackTopicEnum.generalFeedback);

      default: return FeedbackTopic(topic: FeedbackTopicEnum.other);
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
    }
  }

}