import 'package:admin_dvij/constants/system_constants.dart';
import 'package:admin_dvij/database/image_uploader.dart';
import 'package:admin_dvij/images/image_location.dart';
import 'package:admin_dvij/images/images_list_class.dart';
import 'package:flutter/material.dart';
import '../design_elements/elements_of_design.dart';

class ImageFromDb {
  String id;
  String url;
  ImageLocation location;

  ImageFromDb({required this.id, required this.url, required this.location});

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

  Widget getImageWidget({
    required BuildContext context,
    required VoidCallback onDelete
  }){

    return ElementsOfDesign.imageWithTags(
        imageUrl: url,
        width: double.infinity,
        height: double.infinity,
        needMargin: false,
        rightTopTag: ElementsOfDesign.cleanButton(onClean: onDelete),
        leftBottomTag: ElementsOfDesign.getTag(context: context, text: location.toString())
    );

  }

}