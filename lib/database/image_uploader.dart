import 'dart:io';
import 'package:admin_dvij/constants/system_constants.dart';
import 'package:admin_dvij/database/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

// --- ФУНКЦИИ ЗАГРУЗКИ ИЗОБРАЖЕНИЙ В STORAGE ---

class ImageUploader {
  // Инициализируем Storage
  final FirebaseStorage _storage = FirebaseStorage.instance;

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