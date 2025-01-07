enum FeedbackStatusEnum {
  received,       // Сообщение получено
  inProgress,     // Сообщение обрабатывается
  resolved,       // Проблема решена
  dismissed,      // Сообщение отклонено
  awaitingResponse, // Ожидается ответ от пользователя
  escalated,      // Сообщение передано на более высокий уровень
  closed          // Обработка завершена
}

class FeedbackStatus {
  FeedbackStatusEnum status;

  FeedbackStatus({this.status = FeedbackStatusEnum.received});

  factory FeedbackStatus.fromString({required String status}){
    switch (status) {
      case 'received': return FeedbackStatus(status: FeedbackStatusEnum.received);
      case 'inProgress': return FeedbackStatus(status: FeedbackStatusEnum.inProgress);
      case 'resolved': return FeedbackStatus(status: FeedbackStatusEnum.resolved);
      case 'dismissed': return FeedbackStatus(status: FeedbackStatusEnum.dismissed);
      case 'awaitingResponse': return FeedbackStatus(status: FeedbackStatusEnum.awaitingResponse);
      case 'escalated': return FeedbackStatus(status: FeedbackStatusEnum.escalated);
      case 'closed': return FeedbackStatus(status: FeedbackStatusEnum.closed);
      default: return FeedbackStatus(status: FeedbackStatusEnum.received);
    }
  }

  @override
  String toString({bool translate = false}) {
    switch (status) {
      case FeedbackStatusEnum.received: return !translate ? 'received' : 'Сообщение получено';
      case FeedbackStatusEnum.inProgress: return !translate ? 'inProgress' : 'Сообщение обрабатывается';
      case FeedbackStatusEnum.resolved: return !translate ? 'resolved' : 'Проблема решена';
      case FeedbackStatusEnum.dismissed: return !translate ? 'dismissed' : 'Сообщение отклонено';
      case FeedbackStatusEnum.awaitingResponse: return !translate ? 'awaitingResponse' : 'Ожидается ответ от пользователя';
      case FeedbackStatusEnum.escalated: return !translate ? 'escalated' : 'Сообщение передано на более высокий уровень';
      case FeedbackStatusEnum.closed: return !translate ? 'closed' : 'Обработка завершена';
    }
  }

}