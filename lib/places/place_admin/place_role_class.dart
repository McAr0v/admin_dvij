enum PlaceUserRoleEnum {
  admin,
  org,
  creator,
  reader
}

class PlaceRole {
  PlaceUserRoleEnum role;
  
  PlaceRole({this.role = PlaceUserRoleEnum.reader});

  factory PlaceRole.fromString({required String roleString}){

    switch (roleString) {
      case 'admin': return PlaceRole(role: PlaceUserRoleEnum.admin);
      case 'org': return PlaceRole(role: PlaceUserRoleEnum.org);
      case 'creator': return PlaceRole(role: PlaceUserRoleEnum.creator);
      default: return PlaceRole(role: PlaceUserRoleEnum.reader);
    }
  }

  @override
  String toString({bool needTranslate = false}) {
    switch (role) {
      case PlaceUserRoleEnum.admin: return !needTranslate ? 'admin' : 'Администратор';
      case PlaceUserRoleEnum.org: return !needTranslate ? 'org' : 'Организатор';
      case PlaceUserRoleEnum.creator: return !needTranslate ? 'creator' : 'Создатель';
      case PlaceUserRoleEnum.reader: return !needTranslate ? 'reader' : 'Обычный пользователь';
    }
  }

  String getDesc(){
    switch (role) {
      case PlaceUserRoleEnum.admin: return 'Может редактировать место, добавлять управляющих и менять роли';
      case PlaceUserRoleEnum.org: return 'Может добавлять мероприятия и акции от имени заведения';
      case PlaceUserRoleEnum.creator: return 'Полный доступ ко всем функциям. Единственный кто может удалить место';
      case PlaceUserRoleEnum.reader: return 'Обычный пользователь, который может только читать данные о заведении';
    }
  }

}