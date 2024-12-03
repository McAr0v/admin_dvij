import 'package:admin_dvij/constants/ads_constants.dart';

enum AdLocationEnum {
  places,
  events,
  promos,
  all,
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
      case AdLocationEnum.all:
        return !translate ? AdsConstants.allLocation : AdsConstants.allHeadline;
      case AdLocationEnum.notChosen:
        return !translate ? AdsConstants.notChosenLocation : AdsConstants.notChosenHeadline;
    }
  }

  factory AdLocation.fromString({required String text}){
    switch (text){
      case AdsConstants.placeLocation: return AdLocation(location: AdLocationEnum.places);
      case AdsConstants.promoLocation: return AdLocation(location: AdLocationEnum.promos);
      case AdsConstants.eventLocation: return AdLocation(location: AdLocationEnum.events);
      case AdsConstants.allLocation: return AdLocation(location: AdLocationEnum.all);
      default: return AdLocation(location: AdLocationEnum.notChosen);
    }
  }

}