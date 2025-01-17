import 'package:admin_dvij/images/image_location.dart';

class SystemConstants {

  // Работа с данными
  static const String pathToDb = 'https://dvij-flutter-default-rtdb.firebaseio.com';
  static const String appDesc = 'Административное приложение';
  static const String projectId = 'dvij-flutter';

  // Ответы из БД
  static const String successConst = 'ok';
  static const String nullConst = 'null';
  static const String noDataConst = 'Данные не найдены';
  static const String noIdToken = 'Токен не найден';

  // Уведомления о состоянии экрана
  static const String logIn = 'Вход в аккаунт...';
  static const String logOut = 'Выход из аккаунта...';
  static const String refreshSuccess = 'Список обновлен';
  static const String loadingDefault = 'Подожди чуть-чуть) Идет загрузка';
  static const String emptyList = 'Список пуст';
  static const String saving = 'Сохранение изменений';
  static const String deleting = 'Идет удаление';
  static const String errorLoad = 'Ошибка загрузки';

  static const String awaitingConfirmEmail = 'Ожидаем подтверждения Email';

  // Изображения по умолчанию
  static const String defaultAvatar = 'https://www.shutterstock.com/image-vector/default-avatar-profile-icon-vector-600nw-1745180411.jpg';
  static const String defaultAdImagePath = 'https://firebasestorage.googleapis.com/v0/b/dvij-flutter.appspot.com/o/ad_no_image.jpg?alt=media';
  static const String logoSvgPath = 'assets/logo.svg';
  static const String noImagePath = 'https://firebasestorage.googleapis.com/v0/b/dvij-flutter.appspot.com/o/no_image.jpg?alt=media';

  // Сообщения о заполнении полей
  static const String noEmail = 'Поле Email не заполнено';
  static const String noPassword = 'Поле с паролем не заполнено';
  static const String fillAllFields = 'Пожалуйста, заполните все поля';
  static const String inputNameOrEmail = 'Введи имя или Email для поиска';

  static const String activeStatus = 'Активно';
  static const String finishedStatus = 'Завершено';
  static const String deletingSuccess = 'Успешно удалено';
  static const String deletingImpossible = 'Удаление невозможно';
  static const String savingSuccess = 'Успешно сохранено!';

  static const String noMessages = 'Сообщений нет';
  static const String enterTextMessage = 'Напишите текст сообщения...';

  static String requestAnswerNegative(String message){
    return 'По запросу $message ничего не найдено';
  }


  static String getStoragePath(){
    return 'https://firebasestorage.googleapis.com/v0/b/$projectId.appspot.com';
  }

  static String getStorageFolderPath({required ImageLocation location}){
    return "${getStoragePath()}/o?prefix=${location.getPath()}/";
  }

  static String getImageUrl({required String encodedPath, required String idToken}){
    return "${getStoragePath()}/o/$encodedPath?alt=media&token=$idToken";
  }

}

