import 'dart:io';
import 'package:admin_dvij/constants/images_constants.dart';
import 'package:admin_dvij/constants/system_constants.dart';
import 'package:admin_dvij/database/image_uploader.dart';
import 'package:admin_dvij/feedback/feedback_class.dart';
import 'package:admin_dvij/feedback/feedback_list_class.dart';
import 'package:admin_dvij/feedback/feedback_view_chat_screen.dart';
import 'package:admin_dvij/images/image_location.dart';
import 'package:admin_dvij/images/images_list_class.dart';
import 'package:flutter/material.dart';
import '../ads/ad_class.dart';
import '../ads/ad_view_create_edit_screen.dart';
import '../ads/ads_list_class.dart';
import '../design/app_colors.dart';
import '../design_elements/elements_of_design.dart';
import '../events/event_class.dart';
import '../events/event_create_view_edit_screen.dart';
import '../events/events_list_class.dart';
import '../places/place_class.dart';
import '../places/place_create_view_edit_screen.dart';
import '../places/places_list_class.dart';
import '../promos/promo_class.dart';
import '../promos/promo_create_edit_view_screen.dart';
import '../promos/promos_list_class.dart';
import '../users/admin_user/admin_user_class.dart';
import '../users/admin_user/admin_users_list.dart';
import '../users/admin_user/profile_screen.dart';
import '../users/simple_users/simple_user.dart';
import '../users/simple_users/simple_user_screen.dart';
import '../users/simple_users/simple_users_list.dart';

class ImageFromDb {
  String id;
  String url;
  ImageLocation location;

  ImageFromDb({
    required this.id,
    required this.url,
    required this.location
  });

  factory ImageFromDb.empty(){
    return ImageFromDb(
        id: '',
        url: '',
        location: ImageLocation()
    );
  }

  Future<String> deleteFromDb() async {

    ImagesList imagesListClass = ImagesList();

    ImageUploader ip = ImageUploader();

    String result = '';

    result = await ip.removeImage(entityId: id, folder: location.getPath());

    if (result == SystemConstants.successConst){
      imagesListClass.deleteEntityFromDownloadedList(id);
    }

    return result;
  }

  bool checkLocation({required ImageLocation locationFromFilter}){
    return location.location == locationFromFilter.location;
  }

  String getEntityName(){
    switch (location.location){
      case ImageLocationEnum.notChosen: return '';
      case ImageLocationEnum.admins: {
        AdminUserClass tempAdmin = AdminUsersListClass().getEntityFromList(id);
        if (tempAdmin.uid.isNotEmpty) {
          return tempAdmin.getFullName();
        }
      }
      case ImageLocationEnum.events: {
        EventClass tempEvent = EventsListClass().getEntityFromList(id);
        if (tempEvent.id.isNotEmpty){
          return tempEvent.headline;
        }
      }
      case ImageLocationEnum.users: {
        SimpleUser tempUser = SimpleUsersList().getEntityFromList(id);
        if (tempUser.uid.isNotEmpty){
          return tempUser.getFullName();
        }
      }
      case ImageLocationEnum.ads: {
        AdClass tempAd = AdsList().getEntityFromList(id);
        if (tempAd.id.isNotEmpty) {
          return tempAd.headline;
        }
      }
      case ImageLocationEnum.places: {
        Place tempPlace =  PlacesList().getEntityFromList(id);
        if (tempPlace.id.isNotEmpty){
          return tempPlace.name;
        }
      }
      case ImageLocationEnum.promos: {
        Promo tempPromo = PromosListClass().getEntityFromList(id);
        if (tempPromo.id.isNotEmpty) {
          return tempPromo.headline;
        }
      }

      case ImageLocationEnum.feedback: {
        FeedbackCustom tempFeedback = FeedbackListClass().getEntityFromListByMessageId(id);
        if (tempFeedback.id.isNotEmpty) {
          return tempFeedback.topic.toString(translate: true);
        }
      }
    }
    return ImagesConstants.entityNotFind;
  }

  dynamic getPage({required int indexTabPage}){
    switch (location.location){
      case ImageLocationEnum.notChosen: return null;
      case ImageLocationEnum.admins: {
        AdminUserClass tempAdmin = AdminUsersListClass().getEntityFromList(id);
        if (tempAdmin.uid.isNotEmpty) {
          return ProfileScreen(admin: tempAdmin);
        }
      }
      case ImageLocationEnum.events: {
        EventClass tempEvent = EventsListClass().getEntityFromList(id);
        if (tempEvent.id.isNotEmpty){
          return EventCreateViewEditScreen(indexTabPage: indexTabPage, event: tempEvent,);
        }
      }
      case ImageLocationEnum.users: {
        SimpleUser tempUser = SimpleUsersList().getEntityFromList(id);
        if (tempUser.uid.isNotEmpty){
          return SimpleUserScreen(simpleUser: tempUser);
        }
      }
      case ImageLocationEnum.ads: {
        AdClass tempAd = AdsList().getEntityFromList(id);
        if (tempAd.id.isNotEmpty) {
          return AdViewCreateEditScreen(indexTabPage: indexTabPage, ad: tempAd,);
        }
      }
      case ImageLocationEnum.places: {
        Place tempPlace =  PlacesList().getEntityFromList(id);
        if (tempPlace.id.isNotEmpty){
          return PlaceCreateViewEditScreen(place: tempPlace);
        }
      }
      case ImageLocationEnum.promos: {
        Promo tempPromo = PromosListClass().getEntityFromList(id);
        if (tempPromo.id.isNotEmpty) {
          return PromoCreateViewEditScreen(indexTabPage: indexTabPage, promo: tempPromo,);
        }
      }

      case ImageLocationEnum.feedback: {
        FeedbackCustom tempFeedback = FeedbackListClass().getEntityFromListByMessageId(id);
        if (tempFeedback.id.isNotEmpty) {
          return FeedbackViewChatScreen(feedback: tempFeedback);
        }
      }

    }
    return null;
  }

  Widget getImageWidget({
    required BuildContext context,
    required VoidCallback onDelete,
    required VoidCallback onTap,
  }){

    String entityName = getEntityName();

    return GestureDetector(
      onTap: onTap,
      child: ElementsOfDesign.imageWithTags(
          imageUrl: url,
          width: double.infinity,
          height: double.infinity,
          needMargin: false,
          rightTopTag: entityName == ImagesConstants.entityNotFind ? ElementsOfDesign.cleanButton(onClean: onDelete) : null,
          leftBottomTag: SizedBox(
            width: Platform.isIOS || Platform.isAndroid ? 165 : 200,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Text(
                      entityName,
                      softWrap: false,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium!,
                    ),

                    const SizedBox(height: 5,),

                    Text(
                      location.toString(),
                      softWrap: false,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelMedium!.copyWith(color: AppColors.greyText),
                    ),

                    Text(
                      id,
                      softWrap: false,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelMedium!.copyWith(color: AppColors.greyText),
                    ),
                  ],
                ),
              ),
            ),
          )
      ),
    );

  }

}