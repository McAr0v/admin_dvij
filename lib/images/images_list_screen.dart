import 'package:admin_dvij/database/image_uploader.dart';
import 'package:admin_dvij/design_elements/elements_of_design.dart';
import 'package:admin_dvij/images/image_from_db.dart';
import 'package:admin_dvij/images/image_location.dart';
import 'package:admin_dvij/images/images_list_class.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../constants/system_constants.dart';
import '../design/app_colors.dart';
import '../design/loading_screen.dart';
import '../navigation/drawer_custom.dart';

class ImagesListScreen extends StatefulWidget {
  const ImagesListScreen({Key? key}) : super(key: key);

  @override
  State<ImagesListScreen> createState() => _ImagesListScreenState();
}

class _ImagesListScreenState extends State<ImagesListScreen> {

  List<ImageFromDb> imagesList = [];
  bool loading = false;
  bool deleting = false;
  ImagesList imagesListClass = ImagesList();
  ImageUploader imageUploader = ImageUploader();

  @override
  void initState() {
    initialization();
    super.initState();
  }

  Future<void> initialization ({bool fromDb = false}) async {
    setState(() {
      loading = true;
    });

    imagesList = await imagesListClass.getAllUnusedImages();


    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        title: const Text('Неиспользуемые картинки'),
        actions: [

          // КНОПКИ В AppBar

          // Кнопка "Обновить"
          IconButton(
            onPressed: () async {
              await initialization(fromDb: true);
            },
            icon: const Icon(FontAwesomeIcons.arrowsRotate, size: 15, color: AppColors.white,),
          ),
        ],
      ),

      drawer: const CustomDrawer(),

      body: Stack(
        children: [
          if (loading) const LoadingScreen(loadingText: 'Загрузка изображений')
          else if (deleting) const LoadingScreen(loadingText: 'Удаляем изображение')
          else Column(
              children: [

                if (imagesList.isEmpty) const Expanded(
                    child: Center(
                      child: Text(SystemConstants.emptyList),
                    )
                ),

                if (imagesList.isNotEmpty) Expanded(
                    child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(10, 0, 10, 30),
                        itemCount: imagesList.length,
                        itemBuilder: (context, index) {

                          ImageFromDb tempImage = imagesList[index];

                          return ElementsOfDesign.getImageFromUrl(imageUrl: tempImage.url);

                        }
                    )
                )

              ],
            ),
        ],
      ),
    );
  }
}
