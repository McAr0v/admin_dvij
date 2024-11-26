import 'package:admin_dvij/design/loading_screen.dart';
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
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        //width: MediaQuery.of(context).size.width * 0.95,
        //height: MediaQuery.of(context).size.height * 0.85,
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: AppColors.greyBackground,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Выберите пол',
                    style: Theme.of(context).textTheme.displayMedium,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),

            const SizedBox(height: 10,),
            SingleChildScrollView(
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
          ],
        ),
      ),
    );
  }
}