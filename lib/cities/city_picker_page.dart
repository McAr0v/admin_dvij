import 'package:admin_dvij/constants/city_constants.dart';
import 'package:admin_dvij/design/loading_screen.dart';
import 'package:flutter/material.dart';
import '../constants/system_constants.dart';
import '../design/app_colors.dart';
import 'cities_list_class.dart';
import 'city_class.dart';

class CityPickerPage extends StatefulWidget {

  const CityPickerPage({super.key});

  @override
  State<CityPickerPage> createState() => _CityPickerPageState();
}

class _CityPickerPageState extends State<CityPickerPage> {
  TextEditingController searchController = TextEditingController();
  List<City> filteredCities = [];
  List<City> currentCitiesList = [];
  CitiesList citiesList = CitiesList();

  bool loading = false;

  @override
  void initState() {
    super.initState();
    initCities();
  }

  Future<void> initCities() async{
    setState(() {
      loading = true;
    });
    currentCitiesList = await citiesList.getDownloadedList();
    filteredCities = List.from(currentCitiesList);
    setState(() {
      loading = false;
    });
  }

  void updateFilteredCities(String query) {
    setState(() {
      filteredCities = currentCitiesList
          .where((city) =>
          city.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (loading) const LoadingScreen(),
        if (!loading) Container(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          decoration: const BoxDecoration(
            color: AppColors.greyBackground,
            borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [

              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: searchController,
                  decoration: const InputDecoration(
                    hintText: CityConstants.citySearch,
                  ),
                  onChanged: (value) {
                    updateFilteredCities(value);
                  },
                ),
              ),
              const SizedBox(height: 8.0),
              if (filteredCities.isEmpty) Expanded(
                  child: Text(SystemConstants.requestAnswerNegative(searchController.text))
              ),

              if (filteredCities.isNotEmpty) Expanded(
                  child: SingleChildScrollView(
                    child: ListBody(
                      children: filteredCities.map((City city) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.of(context).pop(city);
                          },
                          child: Card(
                            color: AppColors.greyOnBackground,
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Text(city.name),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  )
              ),
            ],
          ),
        ),
      ],
    );
  }
}