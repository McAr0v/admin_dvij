import 'package:admin_dvij/cities/cities_list_class.dart';
import 'package:admin_dvij/cities/city_class.dart';
import 'package:admin_dvij/cities/city_create_or_edit_screen.dart';
import 'package:admin_dvij/cities/city_element_in_list.dart';
import 'package:admin_dvij/constants/city_constants.dart';
import 'package:admin_dvij/constants/screen_constants.dart';
import 'package:admin_dvij/design/loading_screen.dart';
import 'package:admin_dvij/design_elements/elements_of_design.dart';
import 'package:admin_dvij/navigation/drawer_custom.dart';
import 'package:admin_dvij/system_methods/system_methods_class.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../constants/buttons_constants.dart';
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

  SystemMethodsClass sm = SystemMethodsClass();

  final TextEditingController _cityNameController = TextEditingController();

  @override
  void initState() {
    initData();
    super.initState();
  }

  Future<void>initData({bool fromDb = false}) async{
    setState(() {
      loading = true;
    });

    // Подгружаем список
    citiesList = await citiesListManager.getDownloadedList(fromDb: fromDb);

    if (fromDb) {
      //  Если обновляли с БД, выводим оповещение
      _showSnackBar(SystemConstants.refreshSuccess);
    }

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

          // КНОПКИ В AppBar

          // Кнопка "Обновить"
          IconButton(
            onPressed: () async {
              await initData(fromDb: true);
            },
            icon: const Icon(FontAwesomeIcons.arrowsRotate, size: 15, color: AppColors.white,),
          ),

          // Кнопка "Сорировать"
          IconButton(
            onPressed: (){
              sorting();
            },
            icon: Icon(upSorting ? FontAwesomeIcons.sortUp : FontAwesomeIcons.sortDown, size: 15, color: AppColors.white,),
          ),

          // Кнопка "Создать"
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
          if (loading) const LoadingScreen(loadingText: CityConstants.citiesLoading),
          if (!loading) Column(
            children: [

              // ПОЛЕ ПОИСКА

              ElementsOfDesign.getSearchBar(
                  context: context,
                  textController: _cityNameController,
                  labelText: CityConstants.cityNameForField,
                  icon: FontAwesomeIcons.mapLocationDot,
                  onChanged: (value){
                    setState(() {
                      citiesList = CitiesList().searchElementInList(_cityNameController.text);
                    });
                  },
                  onClean: () async {
                    citiesList = await citiesListManager.getDownloadedList(fromDb: false);
                    setState(() {
                      _cityNameController.text = '';
                    });
                  }
              ),

              // СПИСОК

              Expanded(
                child: Column(
                  children: [

                    if (citiesList.isEmpty) const Expanded(
                        child: Center(
                          child: Text(SystemConstants.emptyList),
                        )
                    ),

                    if (citiesList.isNotEmpty) Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(10, 0, 10, 30),
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
                ),
              ),
            ],
          )
        ],
      ),
    );
  }


  Future<void> saveCity(City? city) async{

    // Уходим на страницу создания / редактирования
    // Ждем результат с нее

    final results = await sm.pushToPageWithResult(context: context, page: CityCreateOrEditScreen(city: city));

    // Если результат есть
    if (results != null) {

      setState(() {
        loading = true;
      });

      // Обновляем список
      await initData();

      setState(() {
        loading = false;
      });

      _showSnackBar(CityConstants.citySaveSuccess);
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

  Future<void> deleteCity(City city) async{
    bool? confirmed = await ElementsOfDesign.exitDialog(
        context,
        CityConstants.deleteCityDesc,
        ButtonsConstants.delete,
        ButtonsConstants.cancel,
        CityConstants.deleteCityHeadline
    );

    if (confirmed != null && confirmed) {

      setState(() {
        loading = true;
      });

      String result = await city.deleteFromDb();

      String message = CityConstants.cityDeleteSuccess;

      if (result == SystemConstants.successConst) {
        await initData();

      } else {
        message = result;
      }

      _showSnackBar(message);

      setState(() {
        loading = false;
      });

    }
  }
}

