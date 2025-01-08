import 'dart:io';
import 'package:admin_dvij/constants/feedback_constants.dart';
import 'package:admin_dvij/constants/system_constants.dart';
import 'package:admin_dvij/feedback/feedback_list_class.dart';
import 'package:admin_dvij/interfaces/entity_interface.dart';
import 'package:firebase_database/firebase_database.dart';
import '../constants/database_constants.dart';
import '../database/database_class.dart';
import '../database/image_uploader.dart';

class FeedbackMessage implements IEntity{
  String id;
  DateTime sendTime;
  String feedbackId;
  String userId;
  String adminId;
  String messageText;
  String imageUrl;

  FeedbackMessage({
    required this.id,
    required this.sendTime,
    required this.feedbackId,
    required this.userId,
    required this.adminId,
    required this.messageText,
    required this.imageUrl
  });

  factory FeedbackMessage.empty(){
    return FeedbackMessage(
        id: '',
        sendTime: DateTime.now(),
        feedbackId: '',
        userId: '',
        adminId: '',
        messageText: '',
        imageUrl: ''
    );
  }

  factory FeedbackMessage.fromSnapshot({required DataSnapshot snapshot}){
    return FeedbackMessage(
        id: snapshot.child(DatabaseConstants.id).value.toString(),
        sendTime: DateTime.parse(snapshot.child(DatabaseConstants.sendTime).value.toString()),
        feedbackId: snapshot.child(DatabaseConstants.feedbackId).value.toString(),
        userId: snapshot.child(DatabaseConstants.userId).value.toString(),
        adminId: snapshot.child(DatabaseConstants.adminId).value.toString(),
        messageText: snapshot.child(DatabaseConstants.messageText).value.toString(),
        imageUrl: snapshot.child(DatabaseConstants.imageUrl).value.toString()
    );
  }

  factory FeedbackMessage.fromJson({required Map<String, dynamic> json}){

    return FeedbackMessage(
        id: json[DatabaseConstants.id] ?? '',
        sendTime: DateTime.parse(json[DatabaseConstants.sendTime] ?? ''),
        feedbackId: json[DatabaseConstants.feedbackId] ?? '',
        userId: json[DatabaseConstants.userId] ?? '',
        adminId: json[DatabaseConstants.adminId] ?? '',
        messageText: json[DatabaseConstants.messageText] ?? '',
        imageUrl: json[DatabaseConstants.imageUrl] ?? ''
    );
  }

  @override
  Future<String> deleteFromDb() async {
    final ImageUploader imageUploader = ImageUploader();

    DatabaseClass db = DatabaseClass();

    String path = '${FeedbackConstants.feedbackPath}/$userId/$feedbackId/${DatabaseConstants.messages}/$id';

    String result = '';

    await imageUploader.removeImage(
        folder: FeedbackConstants.feedbackPath,
        entityId: id
    );

    if (!Platform.isWindows){
      result =  await db.deleteFromDb(path);
    } else {
      result = await db.deleteFromDbForWindows(path);
    }

    if (result == SystemConstants.successConst){
      FeedbackListClass feedbackListClass = FeedbackListClass();
      feedbackListClass.deleteMessageFromDownloadedList(message: this);
    }

    return result;

  }

  @override
  Map<String, dynamic> getMap() {
    return <String, dynamic> {
      DatabaseConstants.id: id,
      DatabaseConstants.sendTime: sendTime.toString(),
      DatabaseConstants.feedbackId: feedbackId,
      DatabaseConstants.userId: userId,
      DatabaseConstants.adminId: adminId,
      DatabaseConstants.messageText: messageText,
      DatabaseConstants.imageUrl: imageUrl,
    };
  }

  @override
  Future<String> publishToDb(File? imageFile) async {

    DatabaseClass db = DatabaseClass();
    final ImageUploader imageUploader = ImageUploader();

    // Переменная если будет загружаться изображение
    String? postedImageUrl;

    // Если Id не задан
    if (id == '') {
      // Генерируем ID
      String? idMessage = db.generateKey();

      // Если ID по какой то причине не сгенерировался
      // генерируем вручную
      id = idMessage ?? 'noId_$sendTime';
    }

    if (imageFile != null){

      postedImageUrl = await imageUploader.uploadImage(
          entityId: id,
          pickedFile: imageFile,
          folder: FeedbackConstants.feedbackPath
      );

    }

    imageUrl = postedImageUrl ?? imageUrl;

    String path = '${FeedbackConstants.feedbackPath}/$userId/$feedbackId/${DatabaseConstants.messages}/$id';

    Map <String, dynamic> eventData = getMap();

    String result = '';

    if (!Platform.isWindows){

      result = await db.publishToDB(path, eventData);

    } else {

      result = await db.publishToDBForWindows(path, eventData);

    }

    if (result == SystemConstants.successConst){
      FeedbackListClass feedbackListClass = FeedbackListClass();
      feedbackListClass.addMessageToCurrentDownloadedList(message: this);
    }

    return result;

  }

}