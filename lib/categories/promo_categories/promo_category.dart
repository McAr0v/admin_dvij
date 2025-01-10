import 'dart:io';
import 'package:admin_dvij/categories/promo_categories/promo_categories_list.dart';
import 'package:admin_dvij/constants/fields_constants.dart';
import 'package:admin_dvij/interfaces/entity_interface.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../constants/categories_constants.dart';
import '../../constants/database_constants.dart';
import '../../constants/system_constants.dart';
import '../../database/database_class.dart';
import '../../design/app_colors.dart';
import '../../design_elements/elements_of_design.dart';
import '../../logs/action_class.dart';
import '../../logs/entity_enum.dart';
import '../../logs/log_class.dart';

class PromoCategory implements IEntity{
  String id;
  String name;

  PromoCategory({required this.id, required this.name});

  factory PromoCategory.fromSnapshot({required DataSnapshot snapshot}) {
    return PromoCategory(
      id: snapshot.child(DatabaseConstants.id).value.toString(),
      name: snapshot.child(DatabaseConstants.name).value.toString(),
    );
  }

  factory PromoCategory.fromJson({required Map<String, dynamic> json}){
    return PromoCategory(
        id: json[DatabaseConstants.id] ?? '',
        name: json[DatabaseConstants.name] ?? ''
    );
  }

  factory PromoCategory.empty(){
    return PromoCategory(id: '', name: '');
  }

  @override
  Future<String> deleteFromDb() async {
    DatabaseClass db = DatabaseClass();

    String path = '${CategoriesConstants.promoCategoryPath}/$id/';

    String result = '';

    if (!Platform.isWindows){
      result =  await db.deleteFromDb(path);
    } else {
      result = await db.deleteFromDbForWindows(path);
    }

    if (result == SystemConstants.successConst) {
      // Если удаление прошло успешно, удаляем из общего списка
      PromoCategoriesList promoCategories = PromoCategoriesList();
      promoCategories.deleteEntityFromDownloadedList(id);
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
          entityEnum: EntityEnum.promoCategory,
          actionEnum: ActionEnum.create,
          creatorId: ''
      );

    }

    String path = '${CategoriesConstants.promoCategoryPath}/$id';

    Map <String, dynamic> categoryData = getMap();

    String result = '';

    if (!Platform.isWindows){

      result = await db.publishToDB(path, categoryData);

    } else {

      result = await db.publishToDBForWindows(path, categoryData);

    }

    if (result == SystemConstants.successConst) {
      // Если результат успешный, добавляем в общий сохраненный список
      PromoCategoriesList promoCategories = PromoCategoriesList();
      promoCategories.addToCurrentDownloadedList(this);
    }

    return result;
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

  factory PromoCategory.setCategory({required PromoCategory category}){
    return PromoCategory(id: category.id, name: category.name);
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
        labelText: FieldsConstants.categoryField,
        canEdit: canEdit,
        icon: FontAwesomeIcons.tag,
        context: context,
        readOnly: true,
        onTap: onTap
    );
  }

}