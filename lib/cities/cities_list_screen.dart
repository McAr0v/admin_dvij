import 'package:admin_dvij/cities/cities_list_class.dart';
import 'package:admin_dvij/cities/city_class.dart';
import 'package:admin_dvij/cities/city_element_in_list.dart';
import 'package:admin_dvij/constants/screen_constants.dart';
import 'package:admin_dvij/design/loading_screen.dart';
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

  Future<void>initData() async{
    setState(() {
      loading = true;
    });

    citiesList = await citiesListManager.getCitiesList();

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
            onPressed: (){},
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

                      return CityElementInList(city: citiesList[index]);

                      }
                  )
              )

            ],
          )
        ],
      ),
    );
  }
}

