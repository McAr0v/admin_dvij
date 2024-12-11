class AdsConstants{
  // Location
  static const placeLocation = 'places';
  static const eventLocation = 'events';
  static const promoLocation = 'promos';
  static const mainPageLocation = 'main_page';
  static const notChosenLocation = 'notChosen';
  static const placeHeadline = 'В заведениях';
  static const eventHeadline = 'В мероприятиях';
  static const promoHeadline = 'В акциях';
  static const mainPageHeadline = 'На главной странице';
  static const notChosenHeadline = 'Место не выбрано';

  // tabs
  static const activeTab = 'Активные';
  static const draftTab = 'Черновики';
  static const completedTab = 'Завершенные';

  // screens
  static const editAd = 'Редактирование рекламы';
  static const createAd = 'Создание рекламы';
  static const createAdProcess = 'Идет создание рекламы';
  static const loadingAdProcess = 'Идет загрузка объявлений';
  static const deleteAdProcess = 'Идет удаление рекламы';
  static const editAdProcess = 'Сохранение рекламы';

  // fields

  static const headlineAdField = 'Заголовок рекламы';
  static const statusAdField = 'Статус';
  static const locationAdField = 'Местоположение рекламы';
  static const slotAdField = 'Слот';
  static const descAdField = 'Описание';
  static const orderDateAdField = 'Дата обращения по рекламе';
  static const urlAdField = 'Целевая ссылка';
  static const startDateAdField = 'Начало показов';
  static const endDateAdField = 'Завершение показов';
  static const clientNameAdField = 'Имя заказчика';

  // index
  static const firstIndex = 'first';
  static const secondIndex = 'second';
  static const thirdIndex = 'third';
  static const notChosenIndex = 'notChosen';
  static const firstIndexSlot = 'Слот №1';
  static const secondIndexSlot = 'Слот №2';
  static const thirdIndexSlot = 'Слот №3';
  static const notChosenIndexSlot = 'Слот не выбран';

  // status
  static const activeSystem = 'active';
  static const activeHeadline = 'Активно';
  static const draftSystem = 'draft';
  static const draftHeadline = 'Черновик';
  static const completedSystem = 'completed';
  static const completedHeadline = 'Завершено';
  static const notChosenStatusSystem = 'notChosen';
  static const notChosenStatusHeadline = 'Статус не выбран';

  // database
  static const adsFolder = 'ads';
  static const adsForMainAppFolder = 'ads_for_users';

  static const String saveSuccess = 'Реклама успешно сохранена!';
  static const String searchBarHeadline = 'Название, заказчик, слот, локация...';

  // dates

  static const String startDateHeadline = 'Первый день показов';
  static const String endDateHeadline = 'Последний день показов';
  static const String deleteAdDesc = 'Удаленную рекламу нельзя будет восстановить';
  static const String deleteAdHeadline = 'Удалить рекламу';

  // systems

  static const String slotSelectionError = 'Для активации рекламы нужно выбрать слот';
  static const String placeSelectionError = 'Для активации рекламы нужно выбрать место';
  static const String startDateSelectionError = 'Для активации рекламы нужно выбрать дату начала показа';
  static const String endDateSelectionError = 'Для активации рекламы нужно выбрать дату завершения показа';
  static const String imageSelectionError = 'Для активации рекламы нужно выбрать изображение';
  static const String slotOccupiedError = 'Этот слот на указанные даты уже занят';
  static const String customerDataError = 'Для сохранения рекламы нужно указать данные заказчика';
  static const String titleAndDescriptionError = 'Для сохранения рекламы нужно заполнить заголовок и описание рекламы';
  static const String emptyAdList = 'Нет объявлений';


}