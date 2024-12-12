import 'dart:io';
import 'package:admin_dvij/places/place_admin/place_role_class.dart';
import 'package:firebase_database/firebase_database.dart';

import '../../constants/simple_users_constants.dart';
import '../../constants/system_constants.dart';
import '../../database/database_class.dart';

class PlaceAdmin{
  String placeId;
  PlaceRole placeRole;

  PlaceAdmin({this.placeId = '', required this.placeRole});

  factory PlaceAdmin.empty(){
    return PlaceAdmin(placeRole: PlaceRole());
  }

  factory PlaceAdmin.fromSnapshot(DataSnapshot snapshot){
    return PlaceAdmin(
        placeRole: PlaceRole.fromString(roleString: snapshot.child('roleId').value.toString()),
        placeId: snapshot.child('placeId').value.toString()
    );
  }

  factory PlaceAdmin.fromJson({required Map<String, dynamic> json}){
    return PlaceAdmin(
        placeRole: PlaceRole.fromString(roleString: json['roleId'] ?? ''),
        placeId: json['placeId'] ?? ''
    );
  }


  Map<String, dynamic> getMap(){
    return {
      'roleId': placeRole.toString(),
      'placeId': placeId
    };
  }

  Future<String> deleteFromDb(String userId) async{
    DatabaseClass db = DatabaseClass();

    String path = '${SimpleUsersConstants.usersPath}/$userId/${SimpleUsersConstants.usersMyPlacesFolder}/$placeId';

    String result = '';

    if (!Platform.isWindows){
      result =  await db.deleteFromDb(path);
    } else {
      result = await db.deleteFromDbForWindows(path);
    }

    return result;
  }

  Future<String> publishToDb(String userId) async{
    DatabaseClass db = DatabaseClass();

    String path = '${SimpleUsersConstants.usersPath}/$userId/${SimpleUsersConstants.usersMyPlacesFolder}/$placeId';

    Map <String, dynamic> roleData = getMap();

    String result = '';

    if (!Platform.isWindows){

      result = await db.publishToDB(path, roleData);

    } else {

      result = await db.publishToDBForWindows(path, roleData);

    }

    return result;
  }

}