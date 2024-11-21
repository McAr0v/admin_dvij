import 'package:admin_dvij/cities/cities_list_class.dart';
import 'package:admin_dvij/cities/city_class.dart';
import 'package:admin_dvij/constants/screen_constants.dart';
import 'package:admin_dvij/design/loading_screen.dart';
import 'package:admin_dvij/navigation/drawer_custom.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../constants/system_constants.dart';

class CitiesListScreen extends StatefulWidget {
  const CitiesListScreen({Key? key}) : super(key: key);

  @override
  State<CitiesListScreen> createState() => _CitiesListScreenState();
}

class _CitiesListScreenState extends State<CitiesListScreen> {

  List<City> citiesList = [];

  bool loading = false;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        title: const Text(ScreenConstants.citiesPage),
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
                    padding: EdgeInsets.all(20),
                      itemCount: citiesList.length,
                      itemBuilder: (context, index) {

                      return Row(
                        children: [
                          Text(citiesList[index].name, style: Theme.of(context).textTheme.bodyMedium,),
                          SizedBox(width: 20,),
                          Text(citiesList[index].id, style: Theme.of(context).textTheme.bodyMedium,),

                        ],
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
}

