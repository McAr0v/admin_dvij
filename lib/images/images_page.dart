import 'package:admin_dvij/images/image_location_picker.dart';
import 'package:admin_dvij/images/images_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../constants/buttons_constants.dart';
import '../constants/images_constants.dart';
import '../constants/screen_constants.dart';
import '../constants/system_constants.dart';
import '../design/app_colors.dart';
import '../design/loading_screen.dart';
import '../design_elements/elements_of_design.dart';
import '../navigation/drawer_custom.dart';
import '../system_methods/system_methods_class.dart';
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
  SystemMethodsClass sm = SystemMethodsClass();

  TextEditingController searchingController = TextEditingController();

  Future<void> initialization ({bool fromDb = false}) async {
    setState(() {
      loading = true;
    });

    allImagesList = await imagesListClass.getNeededList(
        isActive: true,
        location: chosenLocation,
        searchingText: searchingController.text,
        fromDb: fromDb
    );
    unusedImagesList = await imagesListClass.getNeededList(
        isActive: false,
        location: chosenLocation,
        searchingText: searchingController.text,
        fromDb: fromDb
    );

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
            Scaffold(
              appBar: AppBar(
                title: const Text(ScreenConstants.imagesPage),
                actions: [

                  // КНОПКИ В AppBar

                  Row(
                    children: [

                      // Кнопка сброса фильтра

                      if (chosenLocation.location != ImageLocationEnum.notChosen)
                        ElementsOfDesign.linkButton(
                            method: () async {
                              await resetFilter();
                            },
                            text: ButtonsConstants.reset,
                            context: context
                        ),

                      if (chosenLocation.location != ImageLocationEnum.notChosen)
                        const SizedBox(width: 10,),

                      // Кнопка "Фильтр"

                      IconButton(
                        onPressed: () async {
                          await filterImages();
                        },
                        icon: Icon(
                          FontAwesomeIcons.filter,
                          size: 15,
                          color: chosenLocation.location != ImageLocationEnum.notChosen ? AppColors.brandColor : AppColors.white,),
                      ),
                    ],
                  ),

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
                    ElementsOfDesign.getTabWithIcon(icon: FontAwesomeIcons.images, text: ImagesConstants.allImagesTab),
                    ElementsOfDesign.getTabWithIcon(icon: FontAwesomeIcons.solidFileImage, text: ImagesConstants.notActiveImagesTab),
                  ],
                ),
              ),

              // СОДЕРЖИМОЕ СТРАНИЦЫ

              body: loading ? const LoadingScreen() :
              deleting ? const LoadingScreen(loadingText: SystemConstants.deleting)
              : Column(
                children: [
                  ElementsOfDesign.getSearchBar(
                      context: context,
                      textController: searchingController,
                      labelText: ImagesConstants.searchFieldHint,
                      icon: FontAwesomeIcons.searchengin,
                      onChanged: (value) async {
                        await searchingAction(text: value);
                      },
                      onClean: () async{
                        await searchingAction(text: '');
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



  Future<void> goToEntity({required ImageFromDb image, required int indexTabPage}) async {
    SystemMethodsClass sm = SystemMethodsClass();

    dynamic page = image.getPage(indexTabPage: indexTabPage);

    if (page != null) {
      final result = await sm.pushToPageWithResult(context: context, page: page);

      if (result != null) {
        await initialization();
      }
    } else {
      _showSnackBar(ImagesConstants.imageNotHaveEntity);
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

  void _showSnackBarTwo(String message) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    });
  }

  Future<void> searchingAction({required String text}) async {
    searchingController.text = text;

    await initialization(
        fromDb: false
    );
  }

  Future<void> resetFilter() async{

    chosenLocation = ImageLocation();
    searchingController.text = '';

    await initialization(fromDb: false);
  }

  Future<void> filterImages() async{

    final result = await sm.getPopup(
        context: context,
        page: const ImageLocationPicker()
    );

    if (result != null){

      chosenLocation = result;
      await initialization(fromDb: false);

    }
  }

}
