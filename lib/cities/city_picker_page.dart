import 'package:admin_dvij/design/loading_screen.dart';
import 'package:flutter/material.dart';
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
    return Scaffold(
      backgroundColor: AppColors.greyBackground.withOpacity(0.5),
      body: Stack(
        children: [
          if (loading) const LoadingScreen(),
          if (!loading) Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.95,
              height: MediaQuery.of(context).size.height * 0.85,
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: AppColors.greyBackground,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Выберите город',
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
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: searchController,
                      decoration: const InputDecoration(
                        hintText: 'Поиск города...',
                      ),
                      onChanged: (value) {
                        updateFilteredCities(value);
                      },
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Expanded(
                      child: Container (
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: AppColors.greyOnBackground,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: SingleChildScrollView(
                          //padding: EdgeInsets.all(15),
                          child: ListBody(
                            children: filteredCities.map((City city) {
                              return GestureDetector(
                                onTap: () {
                                  Navigator.of(context).pop(city);
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(city.name),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      )
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}