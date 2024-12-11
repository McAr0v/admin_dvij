import 'package:firebase_database/firebase_database.dart';

class MethodsForDatabase{

  List<String> getStringFromKeyFromSnapshot({
    required DataSnapshot snapshot,
    required String key
  }){
    List<String> tempList = [];

    for(DataSnapshot idFolders in snapshot.children) {
      String value = idFolders.child(key).value.toString();

      if (value != 'null' && value.isNotEmpty){
        tempList.add(value);
      }
    }
    return tempList;
  }

  List<String> getStringFromKeyFromJson({
    required Map<String, dynamic> json,
    required String inputKey
  }){
    List<String> tempList = [];

    if (json.isNotEmpty){



      json.forEach((key, value) {
        String? tempValue = value[inputKey];
        if (tempValue != null && tempValue.isNotEmpty){
          tempList.add(tempValue);
        }
      });
    }


    return tempList;
  }

}