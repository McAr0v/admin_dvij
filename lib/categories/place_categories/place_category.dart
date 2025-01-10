import 'dart:io';
import 'package:admin_dvij/categories/place_categories/place_categories_list.dart';
import 'package:admin_dvij/constants/places_constants.dart';
import 'package:admin_dvij/design_elements/elements_of_design.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../constants/categories_constants.dart';
import '../../constants/database_constants.dart';
import '../../constants/system_constants.dart';
import '../../database/database_class.dart';
import '../../design/app_colors.dart';
import '../../interfaces/entity_interface.dart';
import '../../logs/action_class.dart';
import '../../logs/entity_enum.dart';
import '../../logs/log_class.dart';

class PlaceCategory implements IEntity {
  String id;
  String name;

  PlaceCategory({required this.name, required this.id});

  factory PlaceCategory.fromSnapshot({required DataSnapshot snapshot}) {
    return PlaceCategory(
      id: snapshot.child(DatabaseConstants.id).value.toString(),
      name: snapshot.child(DatabaseConstants.name).value.toString(),
    );
  }

  factory PlaceCategory.fromJson({required Map<String, dynamic> json}){
    return PlaceCategory(
        id: json[DatabaseConstants.id] ?? '',
        name: json[DatabaseConstants.name] ?? ''
    );
  }

  factory PlaceCategory.empty(){
    return PlaceCategory(id: '', name: '');
  }

  factory PlaceCategory.setCategory({required PlaceCategory category}){
    return PlaceCategory(id: category.id, name: category.name);
  }

  @override
  Future<String> deleteFromDb() async{
    DatabaseClass db = DatabaseClass();

    String path = '${CategoriesConstants.placeCategoryPath}/$id/';

    String result = '';

    if (!Platform.isWindows){
      result =  await db.deleteFromDb(path);
    } else {
      result = await db.deleteFromDbForWindows(path);
    }

    if (result == SystemConstants.successConst) {
      // Если удаление прошло успешно, удаляем из общего списка
      PlaceCategoriesList placesList = PlaceCategoriesList();
      placesList.deleteEntityFromDownloadedList(id);

    }

    return result;
  }

  @override
  Map<String, dynamic> getMap() {
    return <String, dynamic> {
      DatabaseConstants.id: id,
      DatabaseConstants.name: name
    };
  }

  @override
  Future<String> publishToDb(File? imageFile) async{
    DatabaseClass db = DatabaseClass();

    // Если Id не задан
    if (id == '') {
      // Генерируем ID
      String? idCategory = db.generateKey();

      // Если ID по какой то причине не сгенерировался
      // генерируем вручную
      id = idCategory ?? 'noId_$name';

      // Публикуем запись в логе, если создание
      await LogCustom.empty().createAndPublishLog(
          entityId: id,
          entityEnum: EntityEnum.placeCategory,
          actionEnum: ActionEnum.create,
          creatorId: ''
      );

    }

    String path = '${CategoriesConstants.placeCategoryPath}/$id';

    Map <String, dynamic> categoryData = getMap();

    String result = '';

    if (!Platform.isWindows){

      result = await db.publishToDB(path, categoryData);

    } else {

      result = await db.publishToDBForWindows(path, categoryData);

    }

    if (result == SystemConstants.successConst) {
      // Если результат успешный, добавляем в общий сохраненный список
      PlaceCategoriesList placesList = PlaceCategoriesList();
      placesList.addToCurrentDownloadedList(this);
    }
    return result;
  }

  Widget getCategoryFieldWidget({
    required bool canEdit,
    required BuildContext context,
    required VoidCallback onTap
  }){

    TextEditingController categoryController = TextEditingController();
    categoryController.text = name.isNotEmpty ? name : CategoriesConstants.chooseCategory;

    return ElementsOfDesign.buildTextField(
        controller: categoryController,
        labelText: PlacesConstants.categoryPlace,
        canEdit: canEdit,
        icon: FontAwesomeIcons.tag,
        context: context,
        readOnly: true,
        onTap: onTap
    );
  }

  Widget getWidgetElementInList({
    required VoidCallback onEdit,
    required VoidCallback onDelete,
    required BuildContext context
  }){
    return Card(
      color: AppColors.greyOnBackground,
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
        child: Row(
          children: [

            IconButton(
              onPressed: onEdit,
              icon: const Icon(FontAwesomeIcons.penToSquare, size: 15, color: AppColors.brandColor),
            ),

            const SizedBox(width: 20,),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: Theme.of(context).textTheme.bodyMedium,),
                  const SizedBox(width: 20,),
                  Text(id, style: Theme.of(context).textTheme.labelSmall,),

                ],
              ),
            ),

            IconButton(
              onPressed: onDelete,
              icon: const Icon(FontAwesomeIcons.trash, size: 15, color: AppColors.attentionRed,),
            ),

          ],
        ),
      ),
    );
  }

  Widget getCategoryWidget({required BuildContext context}){
    return ElementsOfDesign.getTag(context: context, text: name);
  }
}