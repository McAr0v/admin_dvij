import 'package:admin_dvij/ads/ads_enums_class/ad_location.dart';
import 'package:flutter/material.dart';
import '../../design/app_colors.dart';
import 'ad_status.dart';

class LocationPicker extends StatefulWidget {
  const LocationPicker({Key? key}) : super(key: key);

  @override
  State<LocationPicker> createState() => _LocationPickerState();
}

class _LocationPickerState extends State<LocationPicker> {
  List<AdLocation> locationList = [];

  @override
  void initState() {
    super.initState();
    AdLocation tempLocation = AdLocation(location: AdLocationEnum.notChosen);
    locationList = tempLocation.getLocationList();
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
            children: locationList.map((AdLocation location) {
              return GestureDetector(
                onTap: () {
                  Navigator.of(context).pop(location);
                },
                child: Card(
                  color: AppColors.greyOnBackground,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                      location.toString(translate: true),
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
