import 'dart:io';
import 'package:admin_dvij/constants/feedback_constants.dart';
import 'package:admin_dvij/feedback/feedback_class.dart';
import 'package:admin_dvij/feedback/feedback_message.dart';
import 'package:admin_dvij/interfaces/list_entities_interface.dart';
import 'package:firebase_database/firebase_database.dart';
import '../database/database_class.dart';

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