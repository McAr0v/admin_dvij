import 'dart:io';
import 'package:admin_dvij/cities/cities_list_class.dart';
import 'package:admin_dvij/cities/cities_list_screen.dart';
import 'package:admin_dvij/cities/city_class.dart';
import 'package:admin_dvij/constants/buttons_constants.dart';
import 'package:admin_dvij/constants/city_constants.dart';
import 'package:admin_dvij/constants/system_constants.dart';
import 'package:admin_dvij/design/loading_screen.dart';
import 'package:admin_dvij/design_elements/elements_of_design.dart';
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
      // Если это страница редактирования, то заполняем поле имени
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
    // Метод возвращения на экран списка без результата
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const CitiesListScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {

    // Ограничение ширины на настольных платформах
    bool isDesktop = Platform.isWindows || Platform.isMacOS || Platform.isLinux;
    double maxWidth = isDesktop ? 600 : double.infinity;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.city != null ? CityConstants.editCity : CityConstants.createCity),

        // Задаем особый выход на кнопку назад
        // Чтобы не плодились экраны назад с разным списком сущностей

        leading: IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: navigateToCitiesListScreen,
        ),
      ),

      body: Stack(
        children: [
          if (saving) LoadingScreen(loadingText: widget.city == null ? CityConstants.citiesEditProcess : CityConstants.citiesCreateProcess,),
          if (!saving) Container(
            alignment: Alignment.center,
            child: Container(
              width: maxWidth,
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [

                  Text(
                    widget.city == null ? CityConstants.createCity : '${CityConstants.editCity} ${widget.city!.name}',
                    style: Theme.of(context).textTheme.titleLarge,
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 5,),

                  Text(
                    widget.city == null ? CityConstants.inputCreateCityDesc : CityConstants.inputEditCityDesc,
                    style: Theme.of(context).textTheme.labelMedium,
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 20,),

                  TextField(
                    style: Theme.of(context).textTheme.bodyMedium,
                    keyboardType: TextInputType.text,
                    controller: _cityNameController,
                    decoration: const InputDecoration(
                      labelText: CityConstants.cityNameForField,
                      prefixIcon: Icon(Icons.place),
                    ),
                  ),

                  const SizedBox(height: 20.0),

                  ElementsOfDesign.customButton(
                      method: () async {

                        // Проверки на заполнение полей

                        if (_cityNameController.text.isEmpty){
                          // Если не ввели название
                          _showSnackBar(CityConstants.noCityName);

                        } else if (!citiesList.checkEntityNameInList(_cityNameController.text)){
                          // Если такое название уже есть
                          _showSnackBar(CityConstants.cityAlreadyExists);

                        } else {

                          setState(() {
                            saving = true;
                          });

                          City publishCity = City(
                              id: widget.city != null ? widget.city!.id : '',
                              name: _cityNameController.text
                          );

                          // Публикуем
                          String result = await publishCity.publishToDb(null);

                          if (result == SystemConstants.successConst){

                            // Если успешно, возвращаемся на экран списка с результатом
                            navigateToPreviousScreen();

                          } else {
                            // Если не успешно, выводим причину
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
          ),
        ],
      ),
    );
  }

  // Возвращение на экран списка с результатом
  void navigateToPreviousScreen(){
    List<dynamic> result = [true];
    Navigator.of(context).pop(result);
  }
}
