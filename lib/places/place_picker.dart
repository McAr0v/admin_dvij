import 'package:admin_dvij/design_elements/elements_of_design.dart';
import 'package:admin_dvij/places/place_admin/place_admin_class.dart';
import 'package:admin_dvij/places/place_class.dart';
import 'package:admin_dvij/places/places_list_class.dart';
import 'package:admin_dvij/users/simple_users/simple_user.dart';
import 'package:admin_dvij/users/simple_users/simple_users_list.dart';
import 'package:flutter/material.dart';
import '../design/app_colors.dart';

class PlacePicker extends StatefulWidget {
  final String creatorId;

  const PlacePicker({required this.creatorId, Key? key}) : super(key: key);

  @override
  State<PlacePicker> createState() => _PlacePickerState();
}

class _PlacePickerState extends State<PlacePicker> {

  PlacesList placesList = PlacesList();

  List<Place> usersPlacesList = [];
  SimpleUsersList simpleUsersList = SimpleUsersList();
  SimpleUser currentUser = SimpleUser.empty();


  @override
  void initState() {
    currentUser = simpleUsersList.getEntityFromList(widget.creatorId);

    usersPlacesList = [];

    for (PlaceAdmin admin in currentUser.placesList){

      Place tempPlace = placesList.getEntityFromList(admin.placeId);

      if (tempPlace.id.isNotEmpty){
        usersPlacesList.add(tempPlace);
      }
    }
    super.initState();
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
            children: usersPlacesList.map((Place place) {
              return GestureDetector(
                onTap: () {
                  Navigator.of(context).pop(place);
                },
                child: Card(
                  color: AppColors.greyOnBackground,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      children: [
                        ElementsOfDesign.getAvatar(url: place.imageUrl, size: 30),
                        const SizedBox(width: 20,),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                place.name,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              Text(
                                place.getAddress(),
                                style: Theme.of(context).textTheme.labelMedium!.copyWith(color: AppColors.greyText),
                              ),
                            ],
                          ),
                        ),
                      ],
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
