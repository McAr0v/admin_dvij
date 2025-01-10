class FeedbackConstants {
  static const feedbackPath = 'feedback';
  static const feedbackPathCreatePageHeadline = 'Создание обращения';
  static const feedbackPublishSuccess = 'Ваше обращение успешно опубликовано!';
  static const feedbackNotFillError = 'Обращение заполнено не полностью';
  static const feedbackReceivedTab = 'Поступившие';
  static const feedbackCompletedTab = 'Завершенные';
  static const feedbackInWorkTab = 'В работе';
  static const feedbackSearchBarText = 'Тема, имя, описание...';
  static const feedbackNoRemoveDesc = 'Восстановить данные будет нельзя';

  static String feedbackDeleteQuestion (String id){
    return 'Удалить заявку №$id?';
  }

  static const feedbackSendMessageOnCanEditError = 'Нельзя отправлять сообщение в режиме редактирования';

  static const statusReceived = 'received';
  static const statusReceivedTranslateText = 'Сообщение получено';
  static const statusInProgress = 'inProgress';
  static const statusInProgressTranslateText = 'Сообщение обрабатывается';
  static const statusResolved = 'resolved';
  static const statusResolvedTranslateText = 'Проблема решена';
  static const statusDismissed = 'dismissed';
  static const statusDismissedTranslateText = 'Сообщение отклонено';
  static const statusAwaitingResponse = 'awaitingResponse';
  static const statusAwaitingResponseTranslateText = 'Ожидается ответ от пользователя';
  static const statusEscalated = 'escalated';
  static const statusEscalatedTranslateText = 'Сообщение передано на более высокий уровень';
  static const statusClosed = 'closed';
  static const statusClosedTranslateText = 'Обработка завершена';

  static const topicBugReport = 'bugReport';
  static const topicBugReportTranslateText = 'Сообщение о баге или ошибке в приложении';
  static const topicFeatureRequest = 'featureRequest';
  static const topicFeatureRequestTranslateText = 'Запрос на добавление новой функции';
  static const topicUiUx = 'uiUx';
  static const topicUiUxTranslateText = 'Вопросы, связанные с пользовательским интерфейсом и удобством использования';
  static const topicPerformance = 'performance';
  static const topicPerformanceTranslateText = 'Вопросы, связанные с производительностью приложения';
  static const topicAccountIssues = 'accountIssues';
  static const topicAccountIssuesTranslateText = 'Проблемы, связанные с учетной записью пользователя';
  static const topicPaymentIssues = 'paymentIssues';
  static const topicPaymentIssuesTranslateText = 'Проблемы с оплатой или подпиской';
  static const topicGeneralFeedback = 'generalFeedback';
  static const topicGeneralFeedbackTranslateText = 'Общие отзывы или предложения';
  static const topicOther = 'other';
  static const topicOtherTranslateText = 'Другое';
  static const topicNotChosen = 'notChosen';
  static const topicNotChosenTranslateText = 'Не выбрано';
  static const topicHeadline = 'Тема обращения';

}