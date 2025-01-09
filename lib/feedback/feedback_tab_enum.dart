import 'package:admin_dvij/feedback/feedback_status.dart';
import 'feedback_class.dart';

enum FeedbackTabEnum{
  received,
  inWork,
  completed
}

class FeedbackTabClass {

  bool checkFeedbackToPage ({
    required FeedbackTabEnum tab,
    required FeedbackCustom feedback
  }){

    FeedbackStatusEnum statusEnum = feedback.status.status;

    switch (tab){
      case FeedbackTabEnum.received: return statusEnum == FeedbackStatusEnum.received;
      case FeedbackTabEnum.inWork: return statusEnum == FeedbackStatusEnum.inProgress || statusEnum == FeedbackStatusEnum.awaitingResponse || statusEnum == FeedbackStatusEnum.escalated;
      case FeedbackTabEnum.completed: return statusEnum == FeedbackStatusEnum.resolved || statusEnum == FeedbackStatusEnum.dismissed || statusEnum == FeedbackStatusEnum.closed;
    }
  }

}