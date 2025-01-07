import 'package:admin_dvij/images/image_from_db.dart';
import 'package:flutter/material.dart';
import '../constants/system_constants.dart';

class ImagesListScreen extends StatefulWidget {
  final List<ImageFromDb> imagesList;
  final void Function(int index) deleteImage;
  final void Function(int index) onTapImage;
  const ImagesListScreen({required this.imagesList, required this.deleteImage, required this.onTapImage, Key? key}) : super(key: key);

  @override
  State<ImagesListScreen> createState() => _ImagesListScreenState();
}

class _ImagesListScreenState extends State<ImagesListScreen> {

  @override
  Widget build(BuildContext context) {
    if (widget.imagesList.isEmpty) {
      return const Center(
        child: Text(SystemConstants.emptyList),
      );
    }
    else {
      return Padding(
        padding: const EdgeInsets.all(10.0),
        child: CustomScrollView(
          slivers: <Widget>[
            SliverGrid(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 300.0,
                mainAxisSpacing: 10.0,
                crossAxisSpacing: 10.0,
                childAspectRatio: 1.0,
              ),
              delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {

                  ImageFromDb tempImage = widget.imagesList[index];

                  return tempImage.getImageWidget(
                      context: context,
                      onDelete: () => widget.deleteImage(index),
                      onTap: () => widget.onTapImage(index)
                  );
                },
                childCount: widget.imagesList.length,
              ),
            ),
          ],
        ),
      );
    }
  }

}
