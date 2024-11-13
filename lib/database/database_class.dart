import 'package:admin_dvij/constants/system_constants.dart';
import 'package:firebase_database/firebase_database.dart';

class DatabaseClass{
  final DatabaseReference _reference = FirebaseDatabase.instance.ref();

  Future<DataSnapshot?> getInfoFromDb(String path) async {
    try{
      final DatabaseReference ref = _reference.child(path);
      return await ref.get();
    } catch (e){
      return null;
    }
  }

  Future<String> publishToDB(String path, Map<String, dynamic> data) async {
    try {
      await _reference.child(path).set(data);
      return SystemConstants.successConst;
    } catch (e) {
      return 'Ошибка при публикации данных: $e';
    }
  }

  Future<String> deleteFromDb(String path) async {
    try {
      final DatabaseReference ref = _reference.child(path);

      DataSnapshot snapshot = await ref.get();

      if (!snapshot.exists) {
        return SystemConstants.noDataConst;
      }

      await ref.remove();

      return SystemConstants.successConst;

    } catch (error) {
      return 'Ошибка при удалении: $error';
    }
  }

  String? generateKey() {
    return _reference.push().key;
  }


}