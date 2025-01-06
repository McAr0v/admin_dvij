import 'package:admin_dvij/database/image_uploader.dart';
import 'package:admin_dvij/images/image_from_db.dart';
import 'package:admin_dvij/images/image_location.dart';
import 'package:admin_dvij/users/admin_user/admin_users_list.dart';

class ImagesList {

  Future<List<ImageFromDb>> getAllUnusedImages () async {

    List <ImageFromDb> returnedImages = [];

    ImageUploader im = ImageUploader();
    AdminUsersListClass adminsListClass = AdminUsersListClass();

    List<ImageFromDb> adminsImagesList = await im.getImagesInPath(ImageLocation(location: ImageLocationEnum.admins));
    List<ImageFromDb> adsImagesList = await im.getImagesInPath(ImageLocation(location: ImageLocationEnum.ads));
    List<ImageFromDb> eventsImagesList = await im.getImagesInPath(ImageLocation(location: ImageLocationEnum.events));
    List<ImageFromDb> placesImagesList = await im.getImagesInPath(ImageLocation(location: ImageLocationEnum.places));
    List<ImageFromDb> promosImagesList = await im.getImagesInPath(ImageLocation(location: ImageLocationEnum.promos));
    List<ImageFromDb> usersImagesList = await im.getImagesInPath(ImageLocation(location: ImageLocationEnum.users));

    returnedImages.addAll(await adminsListClass.searchUnusedImages(imagesList: adminsImagesList));

    return returnedImages;

  }
}