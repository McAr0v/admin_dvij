import 'package:admin_dvij/constants/feedback_constants.dart';
import 'package:admin_dvij/constants/fields_constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../design_elements/elements_of_design.dart';

enum FeedbackStatusEnum {
  received,       // Сообщение получено
  inProgress,     // Сообщение обрабатывается
  resolved,       // Проблема решена
  dismissed,      // Сообщение отклонено
  awaitingResponse, // Ожидается ответ от пользователя
  escalated,      // Сообщение передано на более высокий уровень
  closed,          // Обработка завершена
}

class FeedbackStatus {
  FeedbackStatusEnum status;

  FeedbackStatus({this.status = FeedbackStatusEnum.received});

  factory FeedbackStatus.fromString({required String status}){
    switch (status) {
      case FeedbackConstants.statusReceived: return FeedbackStatus(status: FeedbackStatusEnum.received);
      case FeedbackConstants.statusInProgress: return FeedbackStatus(status: FeedbackStatusEnum.inProgress);
      case FeedbackConstants.statusResolved: return FeedbackStatus(status: FeedbackStatusEnum.resolved);
      case FeedbackConstants.statusDismissed: return FeedbackStatus(status: FeedbackStatusEnum.dismissed);
      case FeedbackConstants.statusAwaitingResponse: return FeedbackStatus(status: FeedbackStatusEnum.awaitingResponse);
      case FeedbackConstants.statusEscalated: return FeedbackStatus(status: FeedbackStatusEnum.escalated);
      case FeedbackConstants.statusClosed: return FeedbackStatus(status: FeedbackStatusEnum.closed);
      default: return FeedbackStatus(status: FeedbackStatusEnum.received);
    }
  }

  bool isFinishStatus(){
    switch (status) {
      case FeedbackStatusEnum.resolved: return true;
      case FeedbackStatusEnum.dismissed: return true;
      case FeedbackStatusEnum.closed: return true;
      default: return false;
    }
  }

  List<FeedbackStatus> getStatusList(){
    return [
      FeedbackStatus(status: FeedbackStatusEnum.received),
      FeedbackStatus(status: FeedbackStatusEnum.inProgress),
      FeedbackStatus(status: FeedbackStatusEnum.resolved),
      FeedbackStatus(status: FeedbackStatusEnum.dismissed),
      FeedbackStatus(status: FeedbackStatusEnum.awaitingResponse),
      FeedbackStatus(status: FeedbackStatusEnum.escalated),
      FeedbackStatus(status: FeedbackStatusEnum.closed),
    ];
  }

  @override
  String toString({bool translate = false}) {
    switch (status) {
      case FeedbackStatusEnum.received: return !translate ? FeedbackConstants.statusReceived : FeedbackConstants.statusReceivedTranslateText;
      case FeedbackStatusEnum.inProgress: return !translate ? FeedbackConstants.statusInProgress : FeedbackConstants.statusInProgressTranslateText;
      case FeedbackStatusEnum.resolved: return !translate ? FeedbackConstants.statusResolved : FeedbackConstants.statusResolvedTranslateText;
      case FeedbackStatusEnum.dismissed: return !translate ? FeedbackConstants.statusDismissed : FeedbackConstants.statusDismissedTranslateText;
      case FeedbackStatusEnum.awaitingResponse: return !translate ? FeedbackConstants.statusAwaitingResponse : FeedbackConstants.statusAwaitingResponseTranslateText;
      case FeedbackStatusEnum.escalated: return !translate ? FeedbackConstants.statusEscalated : FeedbackConstants.statusEscalatedTranslateText;
      case FeedbackStatusEnum.closed: return !translate ? FeedbackConstants.statusClosed : FeedbackConstants.statusClosedTranslateText;
    }
  }

  Widget getStatusFieldWidget({
    required bool canEdit,
    required BuildContext context,
    required VoidCallback onTap
  }){

    TextEditingController textController = TextEditingController();
    textController.text = toString(translate: true);

    return ElementsOfDesign.buildTextField(
        controller: textController,
        labelText: FieldsConstants.statusField,
        canEdit: canEdit,
        icon: FontAwesomeIcons.spinner,
        context: context,
        readOnly: true,
        onTap: onTap
    );
  }

}