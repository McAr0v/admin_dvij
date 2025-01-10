import '../constants/action_constants.dart';
import '../constants/database_constants.dart';

enum ActionEnum {
  create,
  delete,
  edit
}

class LogAction {
  ActionEnum action;

  LogAction({required this.action});

  factory LogAction.fromString({required String actionString}){
    switch (actionString) {
      case DatabaseConstants.create: return LogAction(action: ActionEnum.create);
      case DatabaseConstants.delete: return LogAction(action: ActionEnum.delete);
      case DatabaseConstants.edit: return LogAction(action: ActionEnum.edit);
      default: return LogAction(action: ActionEnum.delete);
    }
  }

  @override
  String toString({bool translate = false}) {
    switch (action) {
      case ActionEnum.create: return !translate ? DatabaseConstants.create : ActionConstants.create;
      case ActionEnum.delete: return !translate ? DatabaseConstants.delete : ActionConstants.delete;
      case ActionEnum.edit: return !translate ? DatabaseConstants.edit : ActionConstants.edit;
    }
  }

}