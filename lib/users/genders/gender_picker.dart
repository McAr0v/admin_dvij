import 'package:admin_dvij/users/genders/gender_class.dart';
import 'package:flutter/material.dart';
import '../../design/app_colors.dart';

class GenderPicker extends StatefulWidget {

  const GenderPicker({super.key});

  @override
  State<GenderPicker> createState() => _GenderPickerState();
}

class _GenderPickerState extends State<GenderPicker> {

  List<Gender> gendersList = [];

  @override
  void initState() {
    super.initState();
    Gender tempGender = Gender();
    gendersList = tempGender.getGendersList();
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
          children: gendersList.map((Gender gender) {
            return GestureDetector(
              onTap: () {
                Navigator.of(context).pop(gender);
              },
              child: Card(
                color: AppColors.greyOnBackground,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(
                    gender.toString(needTranslate: true),
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