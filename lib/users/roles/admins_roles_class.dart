
import 'package:admin_dvij/constants/admin_role_constants.dart';

enum AdminRole {
  creator, // Создатель приложения. Его никак нельзя редактировать и удалять. Обаладает всеми правами доступа
  superAdmin, // Полные права: управление пользователями, контентом, настройками и т.д.
  contentManager, // Создание и редактирование контента (постов, объявлений, рекламных материалов и т.д.).
  advertiser, // Только создание и управление рекламными постами.
  editor, // Редактирование существующего контента (объявлений, постов).
  viewer, // Только просмотр данных без возможности их изменения.
  notChosen // Не выбраная роль
}

class AdminRoleClass {

  AdminRole adminRole;

  AdminRoleClass(this.adminRole);

  factory AdminRoleClass.fromString(String adminRole){
    switch (adminRole) {
      case AdminRoleConstants.creator:
        return AdminRoleClass(AdminRole.creator);
      case AdminRoleConstants.superAdmin:
        return AdminRoleClass(AdminRole.superAdmin);
      case AdminRoleConstants.contentManager:
        return AdminRoleClass(AdminRole.contentManager);
      case AdminRoleConstants.advertiser:
        return AdminRoleClass(AdminRole.advertiser);
      case AdminRoleConstants.editor:
        return AdminRoleClass(AdminRole.editor);
      case AdminRoleConstants.viewer:
        return AdminRoleClass(AdminRole.viewer);
      default: return AdminRoleClass(AdminRole.notChosen);
    }
  }

  List<AdminRoleClass> getRolesList(){
    return [
      AdminRoleClass(AdminRole.editor),
      AdminRoleClass(AdminRole.advertiser),
      AdminRoleClass(AdminRole.contentManager),
      AdminRoleClass(AdminRole.superAdmin)
    ];
  }

  @override
  String toString() {
    switch (adminRole) {
      case AdminRole.creator:
        return AdminRoleConstants.creator;
      case AdminRole.superAdmin:
        return AdminRoleConstants.superAdmin;
      case AdminRole.contentManager:
        return AdminRoleConstants.contentManager;
      case AdminRole.advertiser:
        return AdminRoleConstants.advertiser;
      case AdminRole.editor:
        return AdminRoleConstants.editor;
      case AdminRole.viewer:
        return AdminRoleConstants.viewer;
      default:
        return AdminRoleConstants.notChosen; // На случай, если adminRole имеет неизвестное значение.
    }
  }

  /// Метод выдачи доступа на редактирование пользователей
  bool accessToEditUsers(){
    if (adminRole == AdminRole.creator || adminRole == AdminRole.superAdmin) {
      return true;
    } else {
      return false;
    }
  }

  /// Метод выдачи доступа на редактирование пользователей
  bool accessToEditPlaces(){
    if (adminRole == AdminRole.notChosen || adminRole == AdminRole.viewer || adminRole == AdminRole.advertiser) {
      return false;
    } else {
      return true;
    }
  }

  /// Метод разрешения для создателя редактировать все
  bool accessToAll(){
    if (adminRole == AdminRole.creator) {
      return true;
    } else {
      return false;
    }
  }

  bool accessToEditCreator(){
    if (adminRole == AdminRole.creator || adminRole == AdminRole.superAdmin) {
      return true;
    } else {
      return false;
    }
  }

  /// Метод разрешения на редактирование текущего пользователя
  /// <br><br>
  /// Вернет true если пользователь не создатель. Создателя нельзя редактировать никому
  /// кроме создателя
  bool accessToEditingCurrentAdminUser(){
    if (adminRole != AdminRole.creator) {
      return true;
    } else {
      return false;
    }
  }

  String getNameOrDescOfRole (bool needHeadline) {
    switch (adminRole) {
      case AdminRole.creator:
        return needHeadline
            ? AdminRoleConstants.creatorHeadline
            : AdminRoleConstants.creatorDesc;
      case AdminRole.superAdmin:
        return needHeadline
            ? AdminRoleConstants.superAdminHeadline
            : AdminRoleConstants.superAdminDesc;
      case AdminRole.contentManager:
        return needHeadline
            ? AdminRoleConstants.contentManagerHeadline
            : AdminRoleConstants.contentManagerDesc;
      case AdminRole.advertiser:
        return needHeadline
            ? AdminRoleConstants.advertiserHeadline
            : AdminRoleConstants.advertiserDesc;
      case AdminRole.editor:
        return needHeadline
            ? AdminRoleConstants.editorHeadline
            : AdminRoleConstants.editorDesc;
      case AdminRole.viewer:
        return needHeadline
            ? AdminRoleConstants.viewerHeadline
            : AdminRoleConstants.viewerDesc;
      default:
        return needHeadline ? AdminRoleConstants.notChosenHeadline : AdminRoleConstants.notChosenDesc;
    }
  }

}