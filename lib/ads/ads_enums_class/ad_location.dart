import 'package:admin_dvij/constants/ads_constants.dart';

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

}