
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
      case 'creator':
        return AdminRoleClass(AdminRole.creator);
      case 'superAdmin':
        return AdminRoleClass(AdminRole.superAdmin);
      case 'contentManager':
        return AdminRoleClass(AdminRole.contentManager);
      case 'advertiser':
        return AdminRoleClass(AdminRole.advertiser);
      case 'editor':
        return AdminRoleClass(AdminRole.editor);
      case 'viewer':
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
        return 'creator';
      case AdminRole.superAdmin:
        return 'superAdmin';
      case AdminRole.contentManager:
        return 'contentManager';
      case AdminRole.advertiser:
        return 'advertiser';
      case AdminRole.editor:
        return 'editor';
      case AdminRole.viewer:
        return 'viewer';
      default:
        return 'notChosen'; // На случай, если adminRole имеет неизвестное значение.
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

  /// Метод разрешения для создателя редактировать все
  bool accessToAll(){
    if (adminRole == AdminRole.creator) {
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
            ? 'Создатель'
            : 'Создатель приложения. Его никак нельзя редактировать и удалять. Обаладает всеми правами доступа';
      case AdminRole.superAdmin:
        return needHeadline
            ? 'Супер-админ'
            : 'Полные права: управление пользователями, контентом, настройками и т.д.';
      case AdminRole.contentManager:
        return needHeadline
            ? 'Контент-менеджер'
            : 'Создание и редактирование контента (постов, объявлений, рекламных материалов).';
      case AdminRole.advertiser:
        return needHeadline
            ? 'Рекламщик'
            : 'Создание и управление рекламными постами.';
      case AdminRole.editor:
        return needHeadline
            ? 'Редактор'
            : 'Редактирование существующего контента (объявлений, постов).';
      case AdminRole.viewer:
        return needHeadline
            ? 'Просмотр'
            : 'Только просмотр данных без возможности их изменения.';
      default:
        return needHeadline ? 'Неизвестная роль' : 'Роль не определена.';
    }
  }

}