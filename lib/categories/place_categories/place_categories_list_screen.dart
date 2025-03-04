import 'package:admin_dvij/categories/place_categories/place_categories_list.dart';
import 'package:admin_dvij/categories/place_categories/place_category.dart';
import 'package:admin_dvij/categories/place_categories/place_category_create_or_edit_screen.dart';
import 'package:admin_dvij/constants/categories_constants.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../constants/buttons_constants.dart';
import '../../constants/screen_constants.dart';
import '../../constants/system_constants.dart';
import '../../design/app_colors.dart';
import '../../design/loading_screen.dart';
import '../../design_elements/elements_of_design.dart';
import '../../navigation/drawer_custom.dart';
import '../../system_methods/system_methods_class.dart';

class PlaceCategoriesListScreen extends StatefulWidget {
  const PlaceCategoriesListScreen({Key? key}) : super(key: key);

  @override
  State<PlaceCategoriesListScreen> createState() => _PlaceCategoriesListScreenState();
}

class _PlaceCategoriesListScreenState extends State<PlaceCategoriesListScreen> {

  List<PlaceCategory> categoriesList = [];

  bool loading = false;

  bool upSorting = false;

  PlaceCategoriesList categoryListManager = PlaceCategoriesList();

  SystemMethodsClass sm = SystemMethodsClass();

  final TextEditingController _categoryNameController = TextEditingController();

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
    categoriesList = await categoryListManager.getDownloadedList(fromDb: fromDb);

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
      categoriesList.sortPlaceCategories(upSorting);
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        title: const Text(ScreenConstants.placeCategoriesPage),
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
              await saveCategory(null);
            },
            icon: const Icon(FontAwesomeIcons.plus, size: 15, color: AppColors.white,),
          ),

        ],
      ),

      drawer: const CustomDrawer(),

      body: Stack(
        children: [
          if (loading) const LoadingScreen(loadingText: CategoriesConstants.categoriesLoading),
          if (!loading) Column(
            children: [

              // ПОЛЕ ПОИСКА

              ElementsOfDesign.getSearchBar(
                  context: context,
                  textController: _categoryNameController,
                  labelText: CategoriesConstants.categoryNameForField,
                  icon: FontAwesomeIcons.tags,
                  onChanged: (value){
                    setState(() {
                      categoriesList = PlaceCategoriesList().searchElementInList(_categoryNameController.text);
                    });
                  },
                  onClean: () async {
                    categoriesList = await categoryListManager.getDownloadedList(fromDb: false);
                    setState(() {
                      _categoryNameController.text = '';
                    });
                  }
              ),

              // СПИСОК

              Expanded(
                child: Column(
                  children: [

                    if (categoriesList.isEmpty) const Expanded(
                        child: Center(
                          child: Text(SystemConstants.emptyList),
                        )
                    ),

                    if (categoriesList.isNotEmpty) Expanded(
                        child: ListView.builder(
                            padding: const EdgeInsets.fromLTRB(10, 0, 10, 30),
                            itemCount: categoriesList.length,
                            itemBuilder: (context, index) {

                              return categoriesList[index].getWidgetElementInList(
                                  onEdit: () async {
                                    await saveCategory(categoriesList[index]);
                                  },
                                  onDelete: () async {
                                    await deleteCategory(categoriesList[index]);
                                  },
                                  context: context
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

  Future<void> saveCategory(PlaceCategory? category) async{

    // Уходим на страницу создания / редактирования
    // Ждем результат с нее

    final results = await sm.pushToPageWithResult(context: context, page: PlaceCategoryCreateOrEditScreen(category: category));

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

      _showSnackBar(CategoriesConstants.categorySaveSuccess);
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

  Future<void> deleteCategory(PlaceCategory category) async{
    bool? confirmed = await ElementsOfDesign.exitDialog(
        context,
        CategoriesConstants.deleteCategoryDesc,
        ButtonsConstants.delete,
        ButtonsConstants.cancel,
        CategoriesConstants.deleteCategoryHeadline
    );

    if (confirmed != null && confirmed) {

      setState(() {
        loading = true;
      });

      String result = await category.deleteFromDb();

      String message = CategoriesConstants.categoryDeleteSuccess;

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


