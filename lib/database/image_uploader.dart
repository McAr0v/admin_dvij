import 'dart:io';
import 'package:admin_dvij/constants/database_constants.dart';
import 'package:admin_dvij/constants/system_constants.dart';
import 'package:admin_dvij/database/image_picker.dart';
import 'package:admin_dvij/images/image_from_db.dart';
import 'package:admin_dvij/images/image_location.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../auth/auth_class.dart';

// --- ФУНКЦИИ ЗАГРУЗКИ ИЗОБРАЖЕНИЙ В STORAGE ---

class ImageUploader {
  // Инициализируем Storage
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<List<ImageFromDb>>getImageInPath(ImageLocation location) async{
    if (Platform.isWindows){
      return await _getImagesInPathForWindows(location);
    } else {
      return await _getImagesInPathForApp(location);
    }
  }

  /// Метод получения изображений из Storage для всех платформ, кроме Windows
  Future<List<ImageFromDb>> _getImagesInPathForApp(ImageLocation location) async {
    List<ImageFromDb> imagesList = [];
    try {

      // Получаем список всех папок и файлов в `location`
      final ListResult usersFolder = await _storage.ref(location.getPath()).list();

      for (var userFolder in usersFolder.prefixes) { // Перебираем подпапки (id)

        final ListResult images = await userFolder.list();

        for (var fileRef in images.items) { // Перебираем файлы в подпапке


          ImageFromDb tempImage = ImageFromDb.empty();
          tempImage.location = location;
          tempImage.id = userFolder.name;
          tempImage.url = await fileRef.getDownloadURL();
          imagesList.add(tempImage);

        }
      }
    } catch (e) {
      print('Ошибка при получении списка изображений: $e');
    }

    return imagesList;
  }

  /// Метод получения изображений из Storage для Windows
  Future<List<ImageFromDb>> _getImagesInPathForWindows(ImageLocation location) async {
    AuthClass auth = AuthClass();
    String? idToken = await auth.getIdToken();

    List<ImageFromDb> imagesList = [];

    try {
      final response = await http.get(Uri.parse(SystemConstants.getStorageFolderPath(location: location)));

      // Проверяем, если запрос успешен
      if (response.statusCode == 200) {

        // Парсим JSON
        final data = json.decode(response.body);

        // Перебираем все элементы в "items" и создаем объекты ImageFromDb
        for (var item in data[DatabaseConstants.items]) {
          String imagePath = item[DatabaseConstants.name];

          // Кодируем путь, заменяя символы на %2F для правильного URL
          String encodedPath = Uri.encodeComponent(imagePath);

          // Получаем id папки, например, из "admins/GD6QseUWFugc34Itjommb3Xu7OH2/image_GD6QseUWFugc34Itjommb3Xu7OH2.jpeg"
          String id = imagePath.split('/')[1]; // Разделяем строку и получаем id папки

          ImageFromDb tempImage = ImageFromDb(
              id: id,
              url: SystemConstants.getImageUrl(
                  encodedPath: encodedPath,
                  idToken: '$idToken'
              ),
              location: location
          );

          // Добавляем объект в список
          imagesList.add(tempImage);
        }
      } else {
        print('Ошибка: ${response.statusCode}');
      }
    } catch (e) {
      print("Ошибка: $e");
    }

    return imagesList;
  }

  Future<String?> uploadImage({required String entityId, required File pickedFile, required String folder}) async {

    ImagePickerService imagePickerService = ImagePickerService();

    // Сжимаем изображение
    final compressedImage = await imagePickerService.compressImage(pickedFile);

    // Ссылка на ваш объект в Firebase Storage

    final storageRef = _storage.ref().child(folder).child(entityId).child('image_$entityId.jpeg');

    // Выгружаем изображение
    final uploadTask = storageRef.putFile(File(compressedImage.path));

    // Дожидаемся завершения загрузки и получием URL загруженного файла
    final TaskSnapshot taskSnapshot = await uploadTask;
    final downloadURL = await taskSnapshot.ref.getDownloadURL();

    // Возвращаем URL загруженного файла
    return downloadURL;
  }

  Future<String> removeImage({required String entityId, required String folder}) async {

    final storageRef = _storage.ref().child(folder).child(entityId).child('image_$entityId.jpeg');

    try {
      await storageRef.delete();
      return SystemConstants.successConst;
    } on FirebaseException catch (e) {
      return e.toString();
    }
  }

}