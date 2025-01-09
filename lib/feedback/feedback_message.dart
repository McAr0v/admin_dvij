import 'dart:io';
import 'package:admin_dvij/constants/feedback_constants.dart';
import 'package:admin_dvij/constants/system_constants.dart';
import 'package:admin_dvij/design_elements/elements_of_design.dart';
import 'package:admin_dvij/feedback/feedback_list_class.dart';
import 'package:admin_dvij/interfaces/entity_interface.dart';
import 'package:admin_dvij/system_methods/system_methods_class.dart';
import 'package:admin_dvij/users/admin_user/admin_user_class.dart';
import 'package:admin_dvij/users/admin_user/admin_users_list.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../constants/database_constants.dart';
import '../database/database_class.dart';
import '../database/image_uploader.dart';
import '../design/app_colors.dart';
import '../users/simple_users/simple_user.dart';

class FeedbackMessage implements IEntity{
  String id;
  DateTime sendTime;
  String feedbackId;
  String userId;
  String senderId;
  String messageText;
  String imageUrl;

  FeedbackMessage({
    required this.id,
    required this.sendTime,
    required this.feedbackId,
    required this.userId,
    required this.senderId,
    required this.messageText,
    required this.imageUrl
  });

  factory FeedbackMessage.empty(){
    return FeedbackMessage(
        id: '',
        sendTime: DateTime.now(),
        feedbackId: '',
        userId: '',
        senderId: '',
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
        senderId: snapshot.child(DatabaseConstants.senderId).value.toString(),
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
        senderId: json[DatabaseConstants.senderId] ?? '',
        messageText: json[DatabaseConstants.messageText] ?? '',
        imageUrl: json[DatabaseConstants.imageUrl] ?? ''
    );
  }

  bool checkMessageBeforeSending(){
    bool result = false;

    if (feedbackId.isNotEmpty && userId.isNotEmpty && senderId.isNotEmpty && messageText.isNotEmpty){
      return true;
    }

    return result;
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
      DatabaseConstants.senderId: senderId,
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

  Widget getMessageWidget ({
    required SimpleUser client,
    required BuildContext context,
    required VoidCallback onProfileTap,
    required VoidCallback onImageTap,

  }){
    AdminUsersListClass adminUsersList = AdminUsersListClass();
    SystemMethodsClass sm = SystemMethodsClass();
    AdminUserClass admin = AdminUserClass.empty();

    bool isClient = senderId == client.uid;

    if (!isClient) {
      admin = adminUsersList.getEntityFromList(senderId);
    }

    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: isClient ? CrossAxisAlignment.start : CrossAxisAlignment.end,
        mainAxisAlignment: isClient ? MainAxisAlignment.start : MainAxisAlignment.end,
        children: [
          IntrinsicWidth(
            child: Card(
              margin: isClient ? const EdgeInsets.only(top: 10, right: 40, bottom: 10) : const EdgeInsets.only(top: 10, left: 40, bottom: 10),
              color: isClient ? AppColors.greyForCards : AppColors.greyBackground,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    if (imageUrl.isNotEmpty) GestureDetector(
                        onTap: onImageTap,
                        child: ElementsOfDesign.getImageFromUrl(imageUrl: imageUrl),
                    ),

                    if (imageUrl.isNotEmpty) const SizedBox(height: 20,),

                    Text(
                        messageText,
                    ),
                    const SizedBox(height: 10,),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: isClient ? MainAxisAlignment.start : MainAxisAlignment.end,
                      children: [
                        if (isClient) client.getAvatar(size: 20),
                        if (isClient) const SizedBox(width: 10,),
                        Column(
                          crossAxisAlignment: isClient ? CrossAxisAlignment.start : CrossAxisAlignment.end,
                          children: [
                            GestureDetector(
                              onTap: onProfileTap,
                              child: Text(
                                isClient ? client.getFullName() : admin.getFullName(),
                                style: Theme.of(context).textTheme.labelMedium!.copyWith(decoration: TextDecoration.underline),
                              ),
                            ),

                            Row(
                              children: [
                                Icon(FontAwesomeIcons.circleCheck, size: 10,),
                                SizedBox(width: 10,),
                                Text(
                                  sm.formatDateTimeToHumanViewWithClock(sendTime),
                                  style: Theme.of(context).textTheme.labelMedium!.copyWith(color: AppColors.greyText),
                                ),
                              ],
                            )


                          ],
                        ),
                        if (!isClient) const SizedBox(width: 10,),
                        if (!isClient) admin.getAvatar(size: 20),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

}