import 'dart:io';

import 'package:admin_dvij/constants/system_constants.dart';
import 'package:admin_dvij/database/image_uploader.dart';
import 'package:admin_dvij/images/image_location.dart';
import 'package:admin_dvij/images/images_list_class.dart';
import 'package:flutter/material.dart';
import '../ads/ad_class.dart';
import '../ads/ads_list_class.dart';
import '../design/app_colors.dart';
import '../design_elements/elements_of_design.dart';
import '../events/event_class.dart';
import '../events/events_list_class.dart';
import '../places/place_class.dart';
import '../places/places_list_class.dart';
import '../promos/promo_class.dart';
import '../promos/promos_list_class.dart';
import '../users/admin_user/admin_user_class.dart';
import '../users/admin_user/admin_users_list.dart';
import '../users/simple_users/simple_user.dart';
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

  String _getEntityName(){
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
    }
    return 'Сущность не найдена';
  }

  Widget getImageWidget({
    required BuildContext context,
    required VoidCallback onDelete,
    required VoidCallback onTap,
  }){

    return GestureDetector(
      onTap: onTap,
      child: ElementsOfDesign.imageWithTags(
          imageUrl: url,
          width: double.infinity,
          height: double.infinity,
          needMargin: false,
          rightTopTag: ElementsOfDesign.cleanButton(onClean: onDelete),
          leftBottomTag: SizedBox(
            width: Platform.isIOS ? 150 : 200,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Text(
                      _getEntityName(),
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