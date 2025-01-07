import 'package:admin_dvij/images/image_location.dart';
import 'package:flutter/material.dart';
import '../../design/app_colors.dart';

class ImageLocationPicker extends StatefulWidget {

  const ImageLocationPicker({super.key});

  @override
  State<ImageLocationPicker> createState() => _ImageLocationPickerState();
}

class _ImageLocationPickerState extends State<ImageLocationPicker> {

  List<ImageLocation> locationsList = [];

  @override
  void initState() {
    super.initState();
    locationsList = ImageLocation().getLocationsList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      decoration: const BoxDecoration(
        color: AppColors.greyBackground,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
      ),
      child: SingleChildScrollView(
          child: ListBody(
            children: locationsList.map((ImageLocation location) {
              return GestureDetector(
                onTap: () {
                  Navigator.of(context).pop(location);
                },
                child: Card(
                  color: AppColors.greyOnBackground,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                      location.toString(),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ),
              );
            }).toList(),
          )
      ),
    );
  }
}