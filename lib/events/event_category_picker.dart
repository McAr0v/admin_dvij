import 'package:admin_dvij/categories/event_categories/event_categories_list.dart';
import 'package:admin_dvij/categories/event_categories/event_category.dart';
import 'package:admin_dvij/constants/fields_constants.dart';
import 'package:flutter/material.dart';
import '../constants/system_constants.dart';
import '../design/app_colors.dart';
import '../design/loading_screen.dart';

class EventCategoryPicker extends StatefulWidget {
  const EventCategoryPicker({Key? key}) : super(key: key);

  @override
  State<EventCategoryPicker> createState() => _EventCategoryPickerState();
}

class _EventCategoryPickerState extends State<EventCategoryPicker> {
  TextEditingController searchController = TextEditingController();
  List<EventCategory> filteredCategories = [];
  List<EventCategory> currentCategoriesList = [];
  EventCategoriesList categoriesList = EventCategoriesList();

  bool loading = false;

  @override
  void initState() {
    super.initState();
    initCategories();
  }

  Future<void> initCategories() async{
    setState(() {
      loading = true;
    });
    currentCategoriesList = await categoriesList.getDownloadedList();
    filteredCategories = List.from(currentCategoriesList);
    setState(() {
      loading = false;
    });
  }

  void updateFilteredCities(String query) {
    setState(() {
      filteredCategories = currentCategoriesList
          .where((category) =>
          category.name.toLowerCase().contains(query.toLowerCase()))
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
                    hintText: FieldsConstants.categoryNameHintField,
                  ),
                  onChanged: (value) {
                    updateFilteredCities(value);
                  },
                ),
              ),
              const SizedBox(height: 8.0),
              if (filteredCategories.isEmpty) Expanded(
                  child: Text(SystemConstants.requestAnswerNegative(searchController.text))
              ),

              if (filteredCategories.isNotEmpty) Expanded(
                  child: SingleChildScrollView(
                    child: ListBody(
                      children: filteredCategories.map((EventCategory category) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.of(context).pop(category);
                          },
                          child: Card(
                            color: AppColors.greyOnBackground,
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Text(category.name),
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
