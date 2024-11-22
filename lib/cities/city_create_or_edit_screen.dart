import 'dart:io';

import 'package:admin_dvij/cities/cities_list_class.dart';
import 'package:admin_dvij/cities/cities_list_screen.dart';
import 'package:admin_dvij/cities/city_class.dart';
import 'package:admin_dvij/constants/buttons_constants.dart';
import 'package:admin_dvij/constants/system_constants.dart';
import 'package:admin_dvij/database/database_class.dart';
import 'package:admin_dvij/design/loading_screen.dart';
import 'package:admin_dvij/design_elements/elements_of_design.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CityCreateOrEditScreen extends StatefulWidget {

  final City? city;

  const CityCreateOrEditScreen({this.city, Key? key}) : super(key: key);

  @override
  State<CityCreateOrEditScreen> createState() => _CityCreateOrEditScreenState();
}

class _CityCreateOrEditScreenState extends State<CityCreateOrEditScreen> {

  CitiesList citiesList = CitiesList();

  final TextEditingController _cityNameController = TextEditingController();
  bool saving = false;

  @override
  void initState() {
    super.initState();
    saving = false;

    if (widget.city != null) {
      _cityNameController.text = widget.city!.name;
    }

  }

  void _showSnackBar(String message){
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void navigateToCitiesListScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const CitiesListScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {

    bool isDesktop = Platform.isWindows || Platform.isMacOS || Platform.isLinux;
    double maxWidth = isDesktop ? 600 : double.infinity; // Ограничение ширины на настольных платформах

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.city != null ? 'Редактирование города' : 'Создание города'),

        // Задаем особый выход на кнопку назад
        // Чтобы не плодились экраны назад с разным списком городов

        leading: IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: navigateToCitiesListScreen,
        ),
      ),

      body: Center(
        child: Stack(
          children: [
            if (saving) LoadingScreen(loadingText: widget.city == null ? 'Идет публикация города' : 'Идет сохранение города',),
            if (!saving) Container(
              width: maxWidth,
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  TextField(
                    style: Theme.of(context).textTheme.bodyMedium,
                    keyboardType: TextInputType.text,
                    controller: _cityNameController,
                    decoration: const InputDecoration(
                      labelText: 'Название города',
                      prefixIcon: Icon(Icons.place),
                    ),
                  ),

                  const SizedBox(height: 20.0),

                  ElementsOfDesign.customButton(
                      method: () async {

                        if (_cityNameController.text.isEmpty){
                          _showSnackBar('Введите название города!');
                        } else if (!citiesList.checkCityNameInList(_cityNameController.text)){

                          _showSnackBar('Такой город уже есть!');

                        } else {

                          setState(() {
                            saving = true;
                          });

                          City publishCity = City(
                              id: widget.city != null ? widget.city!.id : '',
                              name: _cityNameController.text
                          );

                          String result = await publishCity.publishToDb();

                          if (result == SystemConstants.successConst){

                            navigateToPreviousScreen();

                          } else {
                            _showSnackBar(result);
                          }

                          setState(() {
                            saving = false;
                          });

                        }
                      },
                      textOnButton: ButtonsConstants.save,
                      context: context
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void navigateToPreviousScreen(){
    List<dynamic> result = [true];
    Navigator.of(context).pop(result);
  }
}
