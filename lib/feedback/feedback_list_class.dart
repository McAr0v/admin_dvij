import 'dart:io';
import 'package:admin_dvij/constants/feedback_constants.dart';
import 'package:admin_dvij/feedback/feedback_class.dart';
import 'package:admin_dvij/feedback/feedback_message.dart';
import 'package:admin_dvij/feedback/feedback_tab_enum.dart';
import 'package:admin_dvij/interfaces/list_entities_interface.dart';
import 'package:firebase_database/firebase_database.dart';
import '../database/database_class.dart';
import '../images/image_from_db.dart';
import '../images/image_location.dart';
import 'feedback_topic.dart';

class FeedbackListClass implements IEntitiesList<FeedbackCustom>{
  static List<FeedbackCustom> _currentFeedbackList = [];

  @override
  void addToCurrentDownloadedList(FeedbackCustom entity) {

    // Проверяем, есть ли элемент с таким id
    int index = _currentFeedbackList.indexWhere((c) => c.id == entity.id);

    if (index != -1) {
      // Если элемент с таким id уже существует, заменяем его
      FeedbackCustom tempEntity = _currentFeedbackList[index];

      tempEntity.id = entity.id;
      tempEntity.userId = entity.userId;
      tempEntity.createDate = entity.createDate;
      tempEntity.finishDate = entity.finishDate;
      tempEntity.status = entity.status;
      tempEntity.topic = entity.topic;

      _currentFeedbackList[index] = tempEntity;
    } else {
      // Если элемет с таким id не найден, добавляем новый
      _currentFeedbackList.add(entity);
    }

    _currentFeedbackList.sortFeedback(true);

  }

  Future<List<ImageFromDb>> searchUnusedImages({required List<ImageFromDb> imagesList}) async {

    if (_currentFeedbackList.isEmpty) {
      await getListFromDb();
    }

    List<String> imagesId = [];

    // Создаем Set с ID всех изображений, привязанных к мероприятиям

    for(FeedbackCustom feedback in _currentFeedbackList){
      for (FeedbackMessage message in feedback.messages){
        if (message.imageUrl.isNotEmpty){
          imagesId.add(message.id);
        }
      }
    }

    // Фильтруем список картинок, оставляя только те, которых нет в Set
    return imagesList.where((image) => !imagesId.contains(image.id) && image.location.location == ImageLocationEnum.feedback).toList();

  }

  void addMessageToCurrentDownloadedList({required FeedbackMessage message}){
    // Находим feedback с нужным id
    int index = _currentFeedbackList.indexWhere((c) => c.id == message.feedbackId);

    if (index != -1) {
      // Если Feedback с таким id уже существует, заменяем сообщение в его списке
      FeedbackCustom tempEntity = _currentFeedbackList[index];
      List<FeedbackMessage> tempList = tempEntity.messages;

      // Находим сообщение с нашим id
      int messageIndex = tempList.indexWhere((c) => c.id == message.id);

      if (messageIndex != -1){
        // Если сообщение с таким id уже существует, заменяем его
        tempList[messageIndex] = message;
      } else {
        // Если нет - добавляем сообщение
        tempList.add(message);
      }

      // Заменяем список сообщений у найденого feedback
      tempEntity.messages = tempList;

      // Заменяем весь feedback в списке
      _currentFeedbackList[index] = tempEntity;
    }
  }

  @override
  bool checkEntityNameInList(String entity) {
    if (_currentFeedbackList.any((element) => element.id.toLowerCase() == entity.toLowerCase())) {
      return false;
    } else {
      return true;
    }
  }

  @override
  void deleteEntityFromDownloadedList(String id) {
    if (_currentFeedbackList.isNotEmpty){
      _currentFeedbackList.removeWhere((feedback) => feedback.id == id);
    }
  }

  void deleteMessageFromDownloadedList({required FeedbackMessage message}) {
    if (_currentFeedbackList.isNotEmpty){

      int index = _currentFeedbackList.indexWhere((c) => c.id == message.feedbackId);

      if (index != -1) {
        // Если Feedback с таким id уже существует, заменяем сообщение в его списке
        FeedbackCustom tempEntity = _currentFeedbackList[index];
        List<FeedbackMessage> tempList = tempEntity.messages;

        tempList.removeWhere((feedbackMessage) => feedbackMessage.id == message.id);

        // Заменяем список сообщений у найденого feedback
        tempEntity.messages = tempList;

        // Заменяем весь feedback в списке
        _currentFeedbackList[index] = tempEntity;
      }
    }
  }

  @override
  Future<List<FeedbackCustom>> getDownloadedList({bool fromDb = false}) async {
    if (_currentFeedbackList.isEmpty || fromDb) {
      await getListFromDb();
    }
    return _currentFeedbackList;
  }

  Future<List<FeedbackCustom>> getNeededList({
    bool fromDb = false,
    required FeedbackTopic topic,
    required FeedbackTabEnum tab,
    required String searchingText,
  }) async {

    FeedbackTabClass feedbackTabClass = FeedbackTabClass();
    List<FeedbackCustom> returnedList = [];

    if (_currentFeedbackList.isEmpty || fromDb) {
      await getListFromDb();
    }

    for (FeedbackCustom feedback in _currentFeedbackList){

      if (topic.topic == FeedbackTopicEnum.notChosen){
        if (feedbackTabClass.checkFeedbackToPage(tab: tab, feedback: feedback)){
          returnedList.add(feedback);
        }
      } else {
        if (feedbackTabClass.checkFeedbackToPage(tab: tab, feedback: feedback) && topic.topic == feedback.topic.topic){
          returnedList.add(feedback);
        }
      }

    }

    if (searchingText.isNotEmpty){
      returnedList = returnedList
          .where((feedback) =>
          feedback.id.toLowerCase().contains(searchingText.toLowerCase()) ||
          feedback.topic.toString(translate: true).toLowerCase().contains(searchingText.toLowerCase()) ||
          feedback.status.toString(translate: true).toLowerCase().contains(searchingText.toLowerCase()) ||
          feedback.checkMessagesOnSearchingText(searchingText.toLowerCase()) ||
          feedback.checkUserFullNameOnSearchingText(searchingText.toLowerCase())
      ).toList();
    }

    returnedList.sortFeedback(true);

    return returnedList;
  }

  @override
  FeedbackCustom getEntityFromList(String id) {
    FeedbackCustom returnedFeedback = FeedbackCustom.empty();

    if (_currentFeedbackList.isNotEmpty) {
      for (FeedbackCustom feedback in _currentFeedbackList) {
        if (feedback.id == id) {
          returnedFeedback = feedback;
          break;
        }
      }
    }
    return returnedFeedback;
  }

  FeedbackCustom getEntityFromListByMessageId(String id) {
    FeedbackCustom returnedFeedback = FeedbackCustom.empty();

    if (_currentFeedbackList.isNotEmpty) {
      for (FeedbackCustom feedback in _currentFeedbackList) {
        for (FeedbackMessage message in feedback.messages){
          if (message.id == id) {
            return feedback;
          }
        }
      }
    }
    return returnedFeedback;
  }

  @override
  Future<List<FeedbackCustom>> getListFromDb() async {
    DatabaseClass database = DatabaseClass();

    const String path = FeedbackConstants.feedbackPath;

    List<FeedbackCustom> tempList = [];

    // Подгрузка если платформа не Windows
    if (!Platform.isWindows){
      DataSnapshot? snapshot = await database.getInfoFromDb(path);

      if (snapshot != null && snapshot.exists) {
        for (DataSnapshot userFolder in snapshot.children){
          for(DataSnapshot idFolder in userFolder.children){
            FeedbackCustom tempEntity = FeedbackCustom.fromSnapshot(snapshot: idFolder);
            tempList.add(tempEntity);
          }
        }
      }

    } else {

      // Подгрузка если Windows

      dynamic data = await database.getInfoFromDbForWindows(path);

      if (data != null){
        data.forEach((key, userFolder) {
          userFolder.forEach((key, idFolders) {
            tempList.add(FeedbackCustom.fromJson(json: idFolders));
          });
        });
      }
    }

    // Устанавливаем подгруженный список в нашу доступную переменную
    setDownloadedList(tempList);

    // Сортируем список

    _currentFeedbackList.sortFeedback(true);

    return _currentFeedbackList;
  }

  @override
  List<FeedbackCustom> searchElementInList(String query) {
    List<FeedbackCustom> toReturn = _currentFeedbackList;

    toReturn = toReturn
        .where((place) =>
    place.topic.toString(translate: true).toLowerCase().contains(query.toLowerCase())
        || place.status.toString(translate: true).toLowerCase().contains(query.toLowerCase())
    ).toList();

    return toReturn;
  }

  @override
  void setDownloadedList(List<FeedbackCustom> list) {
    _currentFeedbackList = [];
    _currentFeedbackList = list;
  }


}

extension SortFeedbackListExtension on List<FeedbackCustom> {

  void sortFeedback(bool order) {
    if (order) {
      sort((a, b) => a.createDate.compareTo(b.createDate));
    } else {
      sort((a, b) => b.createDate.compareTo(a.createDate));
    }
  }

}