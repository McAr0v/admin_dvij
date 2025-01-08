import 'package:admin_dvij/constants/images_constants.dart';

enum ImageLocationEnum {
  admins,
  ads,
  events,
  places,
  promos,
  users,
  feedback,
  notChosen
}

class ImageLocation {
  ImageLocationEnum location;

  ImageLocation({this.location = ImageLocationEnum.notChosen});

  @override
  String toString() {
    switch (location) {
      case ImageLocationEnum.admins: return ImagesConstants.adminsLocationHeadline;
      case ImageLocationEnum.ads: return ImagesConstants.adsLocationHeadline;
      case ImageLocationEnum.events: return ImagesConstants.eventsLocationHeadline;
      case ImageLocationEnum.places: return ImagesConstants.placesLocationHeadline;
      case ImageLocationEnum.promos: return ImagesConstants.promosLocationHeadline;
      case ImageLocationEnum.users: return ImagesConstants.usersLocationHeadline;
      case ImageLocationEnum.feedback: return ImagesConstants.feedbackLocationHeadline;
      case ImageLocationEnum.notChosen: return ImagesConstants.notChosenLocationHeadline;
    }
  }

  factory ImageLocation.fromString({required String folderName}){
    switch (folderName){
      case 'admins' : return ImageLocation(location: ImageLocationEnum.admins);
      case 'ads' : return ImageLocation(location: ImageLocationEnum.ads);
      case 'events' : return ImageLocation(location: ImageLocationEnum.events);
      case 'places' : return ImageLocation(location: ImageLocationEnum.places);
      case 'promos' : return ImageLocation(location: ImageLocationEnum.promos);
      case 'users' : return ImageLocation(location: ImageLocationEnum.users);
      case 'feedback' : return ImageLocation(location: ImageLocationEnum.feedback);
      default: return ImageLocation();
    }
  }

  List<ImageLocation> getLocationsList(){
    return [
      ImageLocation(location: ImageLocationEnum.notChosen),
      ImageLocation(location: ImageLocationEnum.users),
      ImageLocation(location: ImageLocationEnum.admins),
      ImageLocation(location: ImageLocationEnum.events),
      ImageLocation(location: ImageLocationEnum.places),
      ImageLocation(location: ImageLocationEnum.promos),
      ImageLocation(location: ImageLocationEnum.ads),
      ImageLocation(location: ImageLocationEnum.feedback),
    ];
  }

  String getPath () {
    switch (location) {
      case ImageLocationEnum.admins: return ImagesConstants.adminsLocationPath;
      case ImageLocationEnum.ads: return ImagesConstants.adsLocationPath;
      case ImageLocationEnum.events: return ImagesConstants.eventsLocationPath;
      case ImageLocationEnum.places: return ImagesConstants.placesLocationPath;
      case ImageLocationEnum.promos: return ImagesConstants.promosLocationPath;
      case ImageLocationEnum.users: return ImagesConstants.usersLocationPath;
      case ImageLocationEnum.feedback: return ImagesConstants.feedbackLocationPath;
      case ImageLocationEnum.notChosen: return ImagesConstants.notChosenLocationPath;
    }
  }

}

