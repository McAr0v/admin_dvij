import 'package:admin_dvij/places/place_admin/place_role_class.dart';
import 'package:flutter/material.dart';
import '../../design/app_colors.dart';

class PlaceRolePicker extends StatefulWidget {
  const PlaceRolePicker({Key? key}) : super(key: key);

  @override
  State<PlaceRolePicker> createState() => _PlaceRolePickerState();
}

class _PlaceRolePickerState extends State<PlaceRolePicker> {

  PlaceRole placeRoleClass = PlaceRole();

  List<PlaceRole> rolesList = [];

  @override
  void initState() {
    rolesList = placeRoleClass.getPlacesRolesList();
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
          children: rolesList.map((PlaceRole role) {
            return GestureDetector(
              onTap: () => Navigator.of(context).pop(role),
              child: Card(
                color: AppColors.greyOnBackground,
                child: Padding(
                    padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(role.toString(needTranslate: true), style: Theme.of(context).textTheme.bodyMedium,),
                      Text(role.getDesc(), style: Theme.of(context).textTheme.labelMedium,),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      )
    );
  }
}
