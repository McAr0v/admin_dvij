class AdminRoleConstants{

  static const creator = 'creator';
  static const creatorHeadline = 'Создатель';
  static const creatorDesc = 'Создатель приложения. Его никак нельзя редактировать и удалять. Обаладает всеми правами доступа';
  static const superAdmin = 'superAdmin';
  static const superAdminHeadline = 'Супер-админ';
  static const superAdminDesc = 'Полные права: управление пользователями, контентом, настройками и т.д.';
  static const contentManager = 'contentManager';
  static const contentManagerHeadline = 'Контент-менеджер';
  static const contentManagerDesc = 'Создание и редактирование контента (постов, объявлений, рекламных материалов).';
  static const advertiser = 'advertiser';
  static const advertiserHeadline = 'Рекламщик';
  static const advertiserDesc = 'Создание и управление рекламными постами.';
  static const editor = 'editor';
  static const editorHeadline = 'Редактор';
  static const editorDesc = 'Редактирование существующего контента (объявлений, постов).';
  static const viewer = 'viewer';
  static const viewerHeadline = 'Просмотр';
  static const viewerDesc = 'Только просмотр данных без возможности их изменения.';
  static const notChosen = 'notChosen';
  static const notChosenHeadline = 'Неизвестная роль';
  static const notChosenDesc = 'Роль не определена.';

  static const addAdmin = 'Добавление админа';
  static const editAdmin = 'Редактирование';
  static const savingAdminProcess = 'Сохранение администратора';
  static const loadingAdminProcess = 'Загрузка админов';
  static const deletingAdminProcess = 'Удаление администратора';

  static const thisIsCreator = 'Это создатель';
  static const cantChangeCreator = 'Создателя нельзя изменить';
  static const adminsInChosenPlace = 'Администраторы в';
  static const deleteAdminDesc = 'Вы не сможете отменить эту операцию. Для восстановления администратора заведения нужно заново добавлять его';
  static const deleteAdminHeadline = 'Удалить пользователя из администраторов?';
  static const deleteAdminSuccess = 'Пользователь удален из администраторов';

}