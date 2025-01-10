import 'package:admin_dvij/auth/auth_class.dart';
import 'package:admin_dvij/constants/system_constants.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;


class DatabaseClass{
  final DatabaseReference _reference = FirebaseDatabase.instance.ref();

  Future<DataSnapshot?> getInfoFromDb(String path) async {

    try{
      final DatabaseReference ref = _reference.child(path);
      DataSnapshot snapshot = await ref.get();
      return snapshot;
    } catch (e){
      return null;
    }
  }

  Future<dynamic> getInfoFromDbForWindows(String path) async {
    try{
      final url = Uri.parse('${SystemConstants.pathToDb}/$path.json');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print(data);
        return data;

      } else {
        return null;
      }
    } catch (e){
      return e;
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

  Future<String> publishToDBForWindows(String path, Map<String, dynamic> data) async {

    AuthClass auth = AuthClass();

    String? idToken = await auth.getIdToken();

    if (idToken != null) {
      final url = Uri.parse('${SystemConstants.pathToDb}/$path.json?auth=$idToken}');
      final response = await http.put(
        url,
        body: json.encode(data),
      );

      if (response.statusCode == 200) {
        return SystemConstants.successConst;
      } else {
        return response.statusCode.toString();
      }
    } else {
      return SystemConstants.noIdToken;
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

  Future<String> deleteFromDbForWindows(String path) async {
    AuthClass auth = AuthClass();

    String? idToken = await auth.getIdToken();

    if (idToken != null) {
      final url = Uri.parse('${SystemConstants.pathToDb}/$path.json?auth=$idToken}');
      final response = await http.delete(url);

      if (response.statusCode == 200) {
        return SystemConstants.successConst;
      } else {
        return response.statusCode.toString();
      }
    } else {
      return SystemConstants.noIdToken;
    }
  }

  String? generateKey() {
    return _reference.push().key;
  }


}