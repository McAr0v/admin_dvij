import 'dart:io';
import 'package:admin_dvij/constants/database_constants.dart';
import 'package:admin_dvij/constants/system_constants.dart';
import 'package:admin_dvij/database/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

// --- ФУНКЦИИ ЗАГРУЗКИ ИЗОБРАЖЕНИЙ В STORAGE ---

class ImageUploader {
  // Инициализируем Storage
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String?> uploadImage(String entityId, File pickedFile) async {

    ImagePickerService imagePickerService = ImagePickerService();

    // Сжимаем изображение
    final compressedImage = await imagePickerService.compressImage(pickedFile);

    // Ссылка на ваш объект в Firebase Storage

    final storageRef = _storage.ref().child(DatabaseConstants.adminsFolder).child(entityId).child('image_$entityId.jpeg');

    // Выгружаем изображение
    final uploadTask = storageRef.putFile(File(compressedImage.path));

    // Дожидаемся завершения загрузки и получием URL загруженного файла
    final TaskSnapshot taskSnapshot = await uploadTask;
    final downloadURL = await taskSnapshot.ref.getDownloadURL();

    // Возвращаем URL загруженного файла
    return downloadURL;
  }

  Future<String> removeImage(String entityId) async {

    final storageRef = _storage.ref().child(DatabaseConstants.adminsFolder).child(entityId).child('image_$entityId.jpeg');

    try {
      await storageRef.delete();
      return SystemConstants.successConst;
    } on FirebaseException catch (e) {
      return e.toString();
    }
  }

}