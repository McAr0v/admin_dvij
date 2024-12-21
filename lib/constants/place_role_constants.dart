class PlaceRoleConstants {
  static const admin = 'admin';
  static const org = 'org';
  static const creator = 'creator';
  static const reader = 'reader';

  static const adminHeadline = 'Администратор';
  static const orgHeadline = 'Организатор';
  static const creatorHeadline = 'Создатель';
  static const readerHeadline = 'Обычный пользователь';


  static const adminDesc = 'Может редактировать место, добавлять управляющих и менять роли';
  static const orgDesc = 'Может добавлять мероприятия и акции от имени заведения';
  static const creatorDesc = 'Полный доступ ко всем функциям. Единственный кто может удалить место';
  static const readerDesc = 'Обычный пользователь, который может только читать данные о заведении';
}