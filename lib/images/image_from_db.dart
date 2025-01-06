import 'dart:io';
import 'package:admin_dvij/constants/system_constants.dart';
import 'package:admin_dvij/database/image_uploader.dart';
import 'package:admin_dvij/images/image_location.dart';
import 'package:admin_dvij/images/images_list_class.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../design/app_colors.dart';
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
    bool isDesktop = Platform.isWindows || Platform.isMacOS || Platform.isLinux;

    if (isDesktop) {
      return _getDescWidget(
          context: context,
          onDelete: onDelete
      );
    } else {
      return _getMobileWidget(
          context: context,
          onDelete: onDelete
      );
    }

  }

  Widget _getDescWidget({
    required BuildContext context,
    required VoidCallback onDelete
  }){
    return Card(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,

        children: [
          Expanded(
            flex: 1,
              child: ElementsOfDesign.imageWithTags(
                  imageUrl: url,
                  width: double.infinity,
                  height: 300,
                  leftTopTag: ElementsOfDesign.cleanButton(onClean: onDelete)
              )
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(location.toString()),
                  const SizedBox(height: 5,),
                  Text(id, style: Theme.of(context).textTheme.labelMedium!.copyWith(color: AppColors.greyText),),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _getMobileWidget({
    required BuildContext context,
    required VoidCallback onDelete
  }){
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ElementsOfDesign.imageWithTags(imageUrl: url, width: double.infinity, height: 200),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(location.toString()),
                      const SizedBox(height: 5,),
                      Text(id, style: Theme.of(context).textTheme.labelMedium!.copyWith(color: AppColors.greyText),),
                    ],
                  ),
                ),

                IconButton(
                    onPressed: onDelete,
                    icon: const Icon(FontAwesomeIcons.x, size: 15,)
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

}