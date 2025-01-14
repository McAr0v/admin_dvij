import 'dart:io';
import 'package:admin_dvij/categories/event_categories/event_categories_list.dart';
import 'package:admin_dvij/categories/event_categories/event_category.dart';
import 'package:admin_dvij/constants/categories_constants.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../constants/buttons_constants.dart';
import '../../constants/system_constants.dart';
import '../../design/loading_screen.dart';
import '../../design_elements/elements_of_design.dart';
import '../../system_methods/system_methods_class.dart';

class EventCategoryCreateOrEditScreen extends StatefulWidget {
  final EventCategory? category;

  const EventCategoryCreateOrEditScreen({this.category, Key? key}) : super(key: key);

  @override
  State<EventCategoryCreateOrEditScreen> createState() => _EventCategoryCreateOrEditScreenState();
}

class _EventCategoryCreateOrEditScreenState extends State<EventCategoryCreateOrEditScreen> {

  EventCategoriesList eventCategoriesList = EventCategoriesList();

  SystemMethodsClass sm = SystemMethodsClass();

  final TextEditingController _categoryNameController = TextEditingController();

  bool saving = false;

  @override
  void initState() {
    super.initState();
    saving = false;

    if (widget.category != null) {
      // Если это страница редактирования, то заполняем поле имени
      _categoryNameController.text = widget.category!.name;
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

  // Возвращение на экран списка с результатом
  void navigateToPreviousScreen(){
    List<dynamic> result = [true];
    sm.popBackToPreviousPageWithResult(context: context, result: result);
  }

  @override
  Widget build(BuildContext context) {
    // Ограничение ширины на настольных платформах
    bool isDesktop = Platform.isWindows || Platform.isMacOS || Platform.isLinux;
    double maxWidth = isDesktop ? 600 : double.infinity;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category != null ? CategoriesConstants.editCategory : CategoriesConstants.createCategory),

        // Задаем особый выход на кнопку назад
        // Чтобы не плодились экраны назад с разным списком сущностей

        leading: IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: navigateToPreviousScreen,
        ),
      ),

      body: Stack(
        children: [
          if (saving) LoadingScreen(loadingText: widget.category == null ? CategoriesConstants.categoryEditProcess : CategoriesConstants.categoryCreateProcess,),
          if (!saving) Container(
            alignment: Alignment.center,
            child: Container(
              width: maxWidth,
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [

                  Text(
                    widget.category == null ? CategoriesConstants.createCategory : '${CategoriesConstants.editCategory} ${widget.category!.name}',
                    style: Theme.of(context).textTheme.titleLarge,
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 5,),

                  Text(
                    widget.category == null ? CategoriesConstants.inputCreateCategoryDesc : CategoriesConstants.inputEditCategoryDesc,
                    style: Theme.of(context).textTheme.labelMedium,
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 20,),

                  TextField(
                    style: Theme.of(context).textTheme.bodyMedium,
                    keyboardType: TextInputType.text,
                    controller: _categoryNameController,
                    decoration: const InputDecoration(
                      labelText: CategoriesConstants.categoryNameForField,
                      prefixIcon: Icon(FontAwesomeIcons.tags),
                    ),
                  ),

                  const SizedBox(height: 20.0),

                  ElementsOfDesign.customButton(
                      method: () async {

                        // Проверки на заполнение полей

                        if (_categoryNameController.text.isEmpty){
                          // Если не ввели название
                          _showSnackBar(CategoriesConstants.noCategoryName);

                        } else if (!eventCategoriesList.checkEntityNameInList(_categoryNameController.text)){
                          // Если такое название уже есть
                          _showSnackBar(CategoriesConstants.categoryAlreadyExists);

                        } else {

                          setState(() {
                            saving = true;
                          });

                          EventCategory publishCategory = EventCategory(
                              id: widget.category != null ? widget.category!.id : '',
                              name: _categoryNameController.text
                          );

                          // Публикуем
                          String result = await publishCategory.publishToDb(null);

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
}
