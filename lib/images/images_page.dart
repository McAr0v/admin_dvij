import 'package:admin_dvij/images/images_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../ads/ad_class.dart';
import '../ads/ad_view_create_edit_screen.dart';
import '../ads/ads_list_class.dart';
import '../constants/buttons_constants.dart';
import '../constants/images_constants.dart';
import '../constants/screen_constants.dart';
import '../constants/system_constants.dart';
import '../design/app_colors.dart';
import '../design/loading_screen.dart';
import '../design_elements/elements_of_design.dart';
import '../events/event_class.dart';
import '../events/event_create_view_edit_screen.dart';
import '../events/events_list_class.dart';
import '../navigation/drawer_custom.dart';
import '../places/place_class.dart';
import '../places/place_create_view_edit_screen.dart';
import '../places/places_list_class.dart';
import '../promos/promo_class.dart';
import '../promos/promo_create_edit_view_screen.dart';
import '../promos/promos_list_class.dart';
import '../system_methods/system_methods_class.dart';
import '../users/admin_user/admin_user_class.dart';
import '../users/admin_user/admin_users_list.dart';
import '../users/admin_user/profile_screen.dart';
import '../users/simple_users/simple_user.dart';
import '../users/simple_users/simple_user_screen.dart';
import '../users/simple_users/simple_users_list.dart';
import 'image_from_db.dart';
import 'image_location.dart';
import 'images_list_class.dart';

class ImagesPage extends StatefulWidget {
  final int initialIndex;

  const ImagesPage({required this.initialIndex, super.key});

  @override
  State<ImagesPage> createState() => _ImagesPageState();
}

class _ImagesPageState extends State<ImagesPage> {

  List<ImageFromDb> allImagesList = [];
  List<ImageFromDb> unusedImagesList = [];
  bool loading = false;
  bool deleting = false;
  ImagesList imagesListClass = ImagesList();

  ImageLocation chosenLocation = ImageLocation();

  // Todo Сделать фильтрацию изображений

  TextEditingController searchingController = TextEditingController();

  Future<void> initialization ({bool fromDb = false}) async {
    setState(() {
      loading = true;
    });

    allImagesList = await imagesListClass.getDownloadedList(fromDb: fromDb);
    unusedImagesList = await imagesListClass.getUnusedImages(fromDb: fromDb);

    setState(() {
      loading = false;
    });
  }

  @override
  void initState() {
    initialization();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        initialIndex: widget.initialIndex,
        length: 2,
        child: Stack(
          children: [
            if (loading) const LoadingScreen()
            else if (deleting) const LoadingScreen(loadingText: SystemConstants.deleting)
            else Scaffold(
              appBar: AppBar(
                title: const Text(ScreenConstants.imagesPage),
                actions: [

                  // КНОПКИ В AppBar

                  /*Row(
                    children: [

                      // Кнопка сброса фильтра

                      if (filterInPlace || filterCategory.id.isNotEmpty || filterCity.name.isNotEmpty)
                        ElementsOfDesign.linkButton(
                            method: () async {
                              await resetFilter();
                            },
                            text: ButtonsConstants.reset,
                            context: context
                        ),

                      if (filterInPlace || filterCategory.id.isNotEmpty || filterCity.name.isNotEmpty)
                        const SizedBox(width: 10,),

                      // Кнопка "Фильтр"

                      IconButton(
                        onPressed: () async {
                          await filterPromos();
                        },
                        icon: Icon(
                          FontAwesomeIcons.filter,
                          size: 15,
                          color: filterInPlace || filterCategory.id.isNotEmpty || filterCity.name.isNotEmpty ? AppColors.brandColor : AppColors.white,),
                      ),
                    ],
                  ),*/

                  // Кнопка "Обновить"
                  IconButton(
                    onPressed: () async {
                      await initialization(fromDb: true);
                    },
                    icon: const Icon(FontAwesomeIcons.arrowsRotate, size: 15, color: AppColors.white,),
                  ),

                ],

                // ТАБЫ

                bottom: TabBar(
                  tabs: [
                    ElementsOfDesign.getTabWithIcon(icon: FontAwesomeIcons.images, text: 'Все изображения'),
                    ElementsOfDesign.getTabWithIcon(icon: FontAwesomeIcons.solidFileImage, text: 'Не активные'),
                  ],
                ),
              ),

              // СОДЕРЖИМОЕ СТРАНИЦЫ

              body: Column(
                children: [
                  ElementsOfDesign.getSearchBar(
                      context: context,
                      textController: searchingController,
                      labelText: 'Локация, id...',
                      icon: FontAwesomeIcons.searchengin,
                      onChanged: (value) async {
                        //await searchingAction(text: value);
                      },
                      onClean: () async{
                        //await searchingAction(text: '');
                      }
                  ),
                  Expanded(
                    child: TabBarView(
                        children: [

                          ImagesListScreen(
                              imagesList: allImagesList,
                              deleteImage: (index) async {
                                await deleteImage(allImagesList[index]);
                              },
                              onTapImage: (index) async {
                                await goToEntity(image: allImagesList[index], indexTabPage: 0);
                              }
                          ),

                          ImagesListScreen(
                              imagesList: unusedImagesList,
                              deleteImage: (index) async {
                                await deleteImage(unusedImagesList[index]);
                              },
                              onTapImage: (index) async {
                                await goToEntity(image: unusedImagesList[index], indexTabPage: 1);
                              }
                          ),

                        ]
                    ),
                  ),
                ],
              ),
              drawer: const CustomDrawer(),
            ),
          ],
        )
    );
  }

  dynamic getPage({required ImageFromDb image, required int indexTabPage}){
    switch (image.location.location){
      case ImageLocationEnum.notChosen: return null;
      case ImageLocationEnum.admins: {
        AdminUserClass tempAdmin = AdminUsersListClass().getEntityFromList(image.id);
        if (tempAdmin.uid.isNotEmpty) {
          return ProfileScreen(admin: tempAdmin);
        }
      }
      case ImageLocationEnum.events: {
        EventClass tempEvent = EventsListClass().getEntityFromList(image.id);
        if (tempEvent.id.isNotEmpty){
          return EventCreateViewEditScreen(indexTabPage: indexTabPage, event: tempEvent,);
        }
      }
      case ImageLocationEnum.users: {
        SimpleUser tempUser = SimpleUsersList().getEntityFromList(image.id);
        if (tempUser.uid.isNotEmpty){
          return SimpleUserScreen(simpleUser: tempUser);
        }
      }
      case ImageLocationEnum.ads: {
        AdClass tempAd = AdsList().getEntityFromList(image.id);
        if (tempAd.id.isNotEmpty) {
          return AdViewCreateEditScreen(indexTabPage: indexTabPage, ad: tempAd,);
        }
      }
      case ImageLocationEnum.places: {
        Place tempPlace =  PlacesList().getEntityFromList(image.id);
        if (tempPlace.id.isNotEmpty){
          return PlaceCreateViewEditScreen(place: tempPlace);
        }
      }
      case ImageLocationEnum.promos: {
        Promo tempPromo = PromosListClass().getEntityFromList(image.id);
        if (tempPromo.id.isNotEmpty) {
          return PromoCreateViewEditScreen(indexTabPage: indexTabPage, promo: tempPromo,);
        }
      }
    }
    return null;
  }

  Future<void> goToEntity({required ImageFromDb image, required int indexTabPage}) async {
    SystemMethodsClass sm = SystemMethodsClass();

    dynamic page = getPage(image: image, indexTabPage: indexTabPage);

    if (page != null) {
      final result = await sm.pushToPageWithResult(context: context, page: page);

      if (result != null) {
        await initialization();
      }
    } else {
      _showSnackBar('Эта картинка не принадлежит ни одной сущности');
    }
  }

  Future<void> deleteImage (ImageFromDb image) async {

    bool? deleteResult = await ElementsOfDesign.exitDialog(
      context,
      ImagesConstants.deleteImageDesc,
      ButtonsConstants.delete,
      ButtonsConstants.cancel,
      ImagesConstants.deleteImageHeadline,
    );

    if (deleteResult != null && deleteResult) {

      setState(() {
        deleting = true;
      });

      String result = await image.deleteFromDb();

      if (result == SystemConstants.successConst) {
        _showSnackBar(SystemConstants.deletingSuccess);
        await initialization();
      } else {
        _showSnackBar(result);
      }

      setState(() {
        deleting = false;
      });
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

  Future<void> searchingAction({required String text}) async {
    searchingController.text = text;

    await initialization(
        fromDb: false
    );
  }

  /*Future<void> resetFilter() async{

    filterInPlace = false;
    filterCategory = PromoCategory.empty();
    filterCity = City.empty();
    searchingController.text = '';

    await initialization(fromDb: false);
  }

  Future<void> filterPromos() async{

    final result = await sm.getPopup(
        context: context,
        page: FilterPromos(
            inPlace: filterInPlace,
            filterCity: filterCity,
            filterCategory: filterCategory
        )
    );

    if (result != null){
      filterCity = result[0];
      filterCategory = result[1];
      filterInPlace = result[2];

      await initialization(fromDb: false);

    }
  }*/

}
