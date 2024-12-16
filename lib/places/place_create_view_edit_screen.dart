import 'dart:io';

import 'package:admin_dvij/categories/place_categories/place_categories_list.dart';
import 'package:admin_dvij/categories/place_categories/place_category.dart';
import 'package:admin_dvij/categories/place_categories/place_category_picker.dart';
import 'package:admin_dvij/cities/cities_list_class.dart';
import 'package:admin_dvij/cities/cities_list_screen.dart';
import 'package:admin_dvij/cities/city_class.dart';
import 'package:admin_dvij/cities/city_picker_page.dart';
import 'package:admin_dvij/places/place_class.dart';
import 'package:admin_dvij/places/places_list_class.dart';
import 'package:admin_dvij/system_methods/system_methods_class.dart';
import 'package:admin_dvij/users/admin_user/admin_user_class.dart';
import 'package:admin_dvij/users/simple_users/creator_popup.dart';
import 'package:admin_dvij/users/simple_users/simple_user.dart';
import 'package:admin_dvij/users/simple_users/simple_users_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';

import '../constants/buttons_constants.dart';
import '../constants/city_constants.dart';
import '../constants/screen_constants.dart';
import '../constants/system_constants.dart';
import '../database/image_picker.dart';
import '../design/app_colors.dart';
import '../design/loading_screen.dart';
import '../design_elements/elements_of_design.dart';

class PlaceCreateViewEditScreen extends StatefulWidget {

  final Place? place;

  const PlaceCreateViewEditScreen({this.place, Key? key}) : super(key: key);

  @override
  State<PlaceCreateViewEditScreen> createState() => _PlaceCreateViewEditScreenState();
}

class _PlaceCreateViewEditScreenState extends State<PlaceCreateViewEditScreen> {

  AdminUserClass currentAdminUser = AdminUserClass.empty();

  PlacesList placesList = PlacesList();
  SimpleUsersList usersList = SimpleUsersList();
  SystemMethodsClass sm = SystemMethodsClass();
  PlaceCategoriesList placeCategoriesList = PlaceCategoriesList();
  CitiesList citiesList = CitiesList();
  final ImagePickerService imagePickerService = ImagePickerService();

  bool loading = false;
  bool saving = false;
  bool canEdit = false;

  File? _imageFile;

  Place editPlace = Place.empty();
  SimpleUser creator = SimpleUser.empty();

  PlaceCategory chosenCategory = PlaceCategory.empty();
  City chosenCity = City.empty();
  SimpleUser chosenCreator = SimpleUser.empty();



  final TextEditingController nameController = TextEditingController();
  final TextEditingController descController = TextEditingController();
  final TextEditingController creatorController = TextEditingController();
  final TextEditingController createDateController = TextEditingController();
  final TextEditingController categoryController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController streetController = TextEditingController();
  final TextEditingController houseController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController whatsappController = TextEditingController();
  final TextEditingController telegramController = TextEditingController();
  final TextEditingController instagramController = TextEditingController();
  final TextEditingController imageController = TextEditingController();

  @override
  void initState() {
    initialization();
    super.initState();
  }

  Future<void> initialization({bool fromDb = false}) async {

    currentAdminUser = await currentAdminUser.getCurrentUser(fromDb: false);

    setState(() {
      loading = true;
    });

    if (fromDb){
      await placesList.getDownloadedList(fromDb: fromDb);
      await usersList.getDownloadedList(fromDb: fromDb);
    }

    if (widget.place == null){
      canEdit = true;
    }

    if (widget.place != null){
      editPlace = placesList.getEntityFromList(widget.place!.id);
      creator = usersList.getEntityFromList(widget.place!.creatorId);
    }

    setTextFieldsOnDefault();

    setState(() {
      loading = false;
    });

  }

  void setTextFieldsOnDefault(){
    setState(() {
      nameController.text = editPlace.name;
      descController.text = editPlace.desc;
      creatorController.text = creator.getFullName().isNotEmpty ? creator.getFullName() : 'Выбери создателя';
      createDateController.text = sm.formatDateTimeToHumanView(editPlace.createDate);
      categoryController.text = editPlace.category.name.isNotEmpty ? editPlace.category.name : 'Категория не выбрана';
      cityController.text = editPlace.city.name.isNotEmpty ? editPlace.city.name : CityConstants.cityNotChosen;
      streetController.text = editPlace.street;
      houseController.text = editPlace.house;
      phoneController.text = editPlace.phone;
      whatsappController.text = editPlace.whatsapp;
      telegramController.text = editPlace.telegram;
      instagramController.text = editPlace.instagram;

      chosenCreator = SimpleUser.empty();
      chosenCategory = PlaceCategory.empty();
      chosenCity = City.empty();

      _imageFile = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600; // Условие для мобильной версии

    return Scaffold(
      appBar: AppBar(
        title: Text(
            'Просмотр заведения'
        ),

        leading: IconButton(
          icon: const Icon(FontAwesomeIcons.chevronLeft, size: 18,),
          onPressed: () {
            sm.popBackToPreviousPageWithResult(context: context, result: true);
          },
        ),

        actions: [

          // Иконка обновления данных.

          IconButton(
            onPressed: () async {
              await initialization(fromDb: true);
            },
            icon: const Icon(FontAwesomeIcons.arrowsRotate, size: 15, color: AppColors.white,),
          ),

          // Иконка редактирования. Доступна если у текущего админа есть доступ

          if (currentAdminUser.adminRole.accessToEditPlaces()) IconButton(
            onPressed: () async {
              setState(() {
                canEdit = true;
              });
            },
            icon: const Icon(FontAwesomeIcons.penToSquare, size: 15, color: AppColors.white,),
          ),

        ],
      ),

      body: Stack(
        children: [
          if (loading) const LoadingScreen(loadingText: SystemConstants.loadingDefault)
          else if (saving) const LoadingScreen(loadingText: SystemConstants.saving)
          else SingleChildScrollView(
              child: Center(
                child: Container(
                  width: sm.getScreenWidth(neededWidth: 800),
                  padding: const EdgeInsets.all(30),
                  margin: EdgeInsets.symmetric(
                      vertical: Platform.isWindows || Platform.isMacOS ? 20 : 10,
                      horizontal: Platform.isWindows || Platform.isMacOS ? 0 : 10
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.greyOnBackground,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [

                      Card(
                          clipBehavior: Clip.antiAlias,
                          child: Stack(
                            children: [

                              ElementsOfDesign.getImageFromUrlOrPickedImage(url: editPlace.imageUrl, imageFile: _imageFile),

                              if (canEdit) Positioned(
                                top: 10,
                                left: 10,
                                child: Card(
                                  color: AppColors.greyBackground,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: ElementsOfDesign.linkButton(
                                        method: () async {
                                          await _pickImage();
                                        },
                                        text: ButtonsConstants.changePhoto,
                                        context: context
                                    ),

                                  ),
                                ),
                              ),
                            ],
                          )
                      ),

                      const SizedBox(height: 20,),

                      ElementsOfDesign.buildAdaptiveRow(
                          isMobile,
                          [
                            ElementsOfDesign.buildTextField(
                                controller: createDateController,
                                labelText: 'Дата создания',
                                canEdit: false,
                                icon: FontAwesomeIcons.idBadge,
                                context: context
                            ),
                            ElementsOfDesign.buildTextField(
                                controller: creatorController,
                                labelText: 'Создатель',
                                canEdit: canEdit && currentAdminUser.adminRole.accessToEditCreator(),
                                icon: FontAwesomeIcons.idBadge,
                                context: context,
                              readOnly: true,
                              onTap: () async {
                                  await chooseCreator();
                              }
                            )
                          ]
                      ),

                      ElementsOfDesign.buildAdaptiveRow(
                          isMobile,
                          [
                            ElementsOfDesign.buildTextField(
                                controller: cityController,
                                labelText: 'Город',
                                canEdit: canEdit,
                                icon: FontAwesomeIcons.idBadge,
                                context: context,
                                readOnly: true,
                                onTap: () async {
                                  await chooseCity();
                                }
                            ),
                            ElementsOfDesign.buildTextField(
                                controller: categoryController,
                                labelText: 'Категория',
                                canEdit: canEdit,
                                icon: FontAwesomeIcons.idBadge,
                                context: context,
                                readOnly: true,
                                onTap: () async {
                                  await chooseCategory();
                                }
                            )
                          ]
                      ),
                      ElementsOfDesign.buildAdaptiveRow(
                          isMobile,
                          [
                            ElementsOfDesign.buildTextField(
                                controller: streetController,
                                labelText: 'Улица',
                                canEdit: canEdit,
                                icon: FontAwesomeIcons.idBadge,
                                context: context
                            ),
                            ElementsOfDesign.buildTextField(
                                controller: houseController,
                                labelText: 'Номер дома',
                                canEdit: canEdit,
                                icon: FontAwesomeIcons.idBadge,
                                context: context,
                            )
                          ]
                      ),

                      ElementsOfDesign.buildAdaptiveRow(
                          isMobile,
                          [
                            ElementsOfDesign.buildTextField(
                                controller: phoneController,
                                labelText: 'Телефон',
                                canEdit: canEdit,
                                icon: FontAwesomeIcons.idBadge,
                                context: context
                            ),
                            ElementsOfDesign.buildTextField(
                              controller: whatsappController,
                              labelText: 'whatsapp',
                              canEdit: canEdit,
                              icon: FontAwesomeIcons.idBadge,
                              context: context,
                            )
                          ]
                      ),

                      ElementsOfDesign.buildAdaptiveRow(
                          isMobile,
                          [
                            ElementsOfDesign.buildTextField(
                                controller: telegramController,
                                labelText: 'Telegram',
                                canEdit: canEdit,
                                icon: FontAwesomeIcons.idBadge,
                                context: context
                            ),
                            ElementsOfDesign.buildTextField(
                              controller: instagramController,
                              labelText: 'instagram',
                              canEdit: canEdit,
                              icon: FontAwesomeIcons.idBadge,
                              context: context,
                            )
                          ]
                      ),

                      ElementsOfDesign.buildTextField(
                          controller: nameController,
                          labelText: 'Название заведения',
                          canEdit: canEdit,
                          icon: FontAwesomeIcons.idBadge,
                          context: context
                      ),

                      const SizedBox(height: 20,),

                      ElementsOfDesign.buildTextField(
                        controller: descController,
                        labelText: 'Описание',
                        canEdit: canEdit,
                        icon: FontAwesomeIcons.fileLines,
                        context: context,
                        maxLines: null,
                      ),

                      const SizedBox(height: 20,),

                    ],
                  ),
                ),
              ),
            )
        ],
      ),

    );
  }

  Future<void> _pickImage() async {

    // TODO - сделать подборщика картинок на macOs

    final File? pickedImage = await imagePickerService.pickImage(ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        _imageFile = pickedImage;
      });
    }
  }

  Future<void> chooseCreator() async{
    final results = await sm.getPopup(context: context, page: const CreatorPopup());
    if (results != null){
      chosenCreator = results;
      creatorController.text = chosenCreator.getFullName();
    }
  }

  Future<void> chooseCity() async{
    final results = await sm.getPopup(context: context, page: const CityPickerPage());
    if (results != null){
      chosenCity = results;
      cityController.text = chosenCity.name;
    }
  }

  Future<void> chooseCategory() async{
    final results = await sm.getPopup(context: context, page: const PlaceCategoryPicker());
    if (results != null){
      chosenCategory = results;
      categoryController.text = chosenCategory.name;
    }
  }

}
