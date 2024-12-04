import 'package:admin_dvij/constants/ads_constants.dart';
import 'package:admin_dvij/design/app_colors.dart';
import 'package:flutter/material.dart';

enum AdLocationEnum {
  places,
  events,
  promos,
  mainPage,
  notChosen
}

class AdLocation {

  AdLocationEnum location;

  AdLocation({required this.location});

  @override
  String toString({bool translate = false}) {
    switch (location) {
      case AdLocationEnum.places:
        return !translate ? AdsConstants.placeLocation : AdsConstants.placeHeadline;
      case AdLocationEnum.promos:
        return !translate ? AdsConstants.promoLocation : AdsConstants.promoHeadline;
      case AdLocationEnum.events:
        return !translate ? AdsConstants.eventLocation : AdsConstants.eventHeadline;
      case AdLocationEnum.mainPage:
        return !translate ? AdsConstants.mainPageLocation : AdsConstants.mainPageHeadline;
      case AdLocationEnum.notChosen:
        return !translate ? AdsConstants.notChosenLocation : AdsConstants.notChosenHeadline;
    }
  }

  factory AdLocation.fromString({required String text}){
    switch (text){
      case AdsConstants.placeLocation: return AdLocation(location: AdLocationEnum.places);
      case AdsConstants.promoLocation: return AdLocation(location: AdLocationEnum.promos);
      case AdsConstants.eventLocation: return AdLocation(location: AdLocationEnum.events);
      case AdsConstants.mainPageLocation: return AdLocation(location: AdLocationEnum.mainPage);
      default: return AdLocation(location: AdLocationEnum.notChosen);
    }
  }

  Widget getStatusWidget({required BuildContext context}){
    return Card(
      color: switchColorWidget(),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Text(toString(translate: true), style: Theme.of(context).textTheme.labelMedium,),
      ),
    );
  }

  Color switchColorWidget(){
    switch (location) {
      case AdLocationEnum.mainPage:
        return AppColors.mainPageLocationColor;
      case AdLocationEnum.events:
        return AppColors.eventLocationColor;
      case AdLocationEnum.places:
        return AppColors.placesLocationColor;
      case AdLocationEnum.promos:
        return AppColors.promotionLocationColor;
      case AdLocationEnum.notChosen:
        return AppColors.greyForCards;
    }
  }

}