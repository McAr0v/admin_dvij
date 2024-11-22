import 'package:admin_dvij/cities/cities_list_class.dart';
import 'package:admin_dvij/cities/city_class.dart';
import 'package:admin_dvij/cities/city_create_or_edit_screen.dart';
import 'package:admin_dvij/cities/city_element_in_list.dart';
import 'package:admin_dvij/constants/screen_constants.dart';
import 'package:admin_dvij/design/loading_screen.dart';
import 'package:admin_dvij/design_elements/elements_of_design.dart';
import 'package:admin_dvij/navigation/drawer_custom.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../constants/system_constants.dart';
import '../design/app_colors.dart';

class CitiesListScreen extends StatefulWidget {
  const CitiesListScreen({Key? key}) : super(key: key);

  @override
  State<CitiesListScreen> createState() => _CitiesListScreenState();
}

class _CitiesListScreenState extends State<CitiesListScreen> {

  List<City> citiesList = [];

  bool loading = false;

  bool upSorting = false;

  CitiesList citiesListManager = CitiesList();

  @override
  void initState() {
    initData();
    super.initState();
  }

  Future<void>initData({bool fromDb = false}) async{
    setState(() {
      loading = true;

    });

    citiesList = await citiesListManager.getCitiesList(fromDb: fromDb);

    setState(() {
      loading = false;
    });

  }

  void sorting () {
    setState(() {
      upSorting = !upSorting;
      citiesList.sortCities(upSorting);
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        title: const Text(ScreenConstants.citiesPage),
        actions: [

          IconButton(
            onPressed: () async {
              await initData(fromDb: true);
            },
            icon: const Icon(FontAwesomeIcons.arrowsRotate, size: 15, color: AppColors.white,),
          ),

          IconButton(
            onPressed: (){},
            icon: const Icon(FontAwesomeIcons.magnifyingGlass, size: 15, color: AppColors.white,),
          ),

          IconButton(
            onPressed: (){
              sorting();
            },
            icon: Icon(upSorting ? FontAwesomeIcons.sortUp : FontAwesomeIcons.sortDown, size: 15, color: AppColors.white,),
          ),



          IconButton(
            onPressed: () async {
              await saveCity(null);
            },
            icon: const Icon(FontAwesomeIcons.plus, size: 15, color: AppColors.white,),
          ),

        ],
      ),

      drawer: const CustomDrawer(),

      body: Stack(
        children: [
          if (loading) const LoadingScreen(loadingText: SystemConstants.citiesLoading),
          if (!loading) Column(
            children: [

              if (citiesList.isEmpty) const Expanded(
                  child: Center(
                    child: Text(SystemConstants.noDataConst),
                  )
              ),

              if (citiesList.isNotEmpty) Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                      itemCount: citiesList.length,
                      itemBuilder: (context, index) {

                      return CityElementInList(
                          city: citiesList[index],
                        onDelete: () async {
                            await deleteCity(citiesList[index]);
                        },
                        onEdit: () async {
                          await saveCity(citiesList[index]);
                        },
                      );

                      }
                  )
              )

            ],
          )
        ],
      ),
    );
  }

  Future<void> saveCity(City? city) async{
    final results = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CityCreateOrEditScreen(city: city),
      ),
    );

    if (results != null) {

      setState(() {
        loading = true;
      });

      await initData();

      // Заменяем мероприятие на обновленное
      setState(() {
        loading = false;
      });
    }
  }

  Future<void> deleteCity(City city) async{
    bool? confirmed = await ElementsOfDesign.exitDialog(
        context,
        'Удаленный элемент нельзя будет восстановить.',
        'Ок',
        'Отмена',
        'Удалить город'
    );

    if (confirmed != null && confirmed) {

      setState(() {
        loading = true;
      });

      String result = await city.deleteFromDb();

      print(result);

      if (result == SystemConstants.successConst) {
        await initData();
      }

      setState(() {
        loading = false;
      });

    }
  }
}

