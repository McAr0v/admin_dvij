import 'dart:io';
import 'package:admin_dvij/constants/simple_users_constants.dart';
import 'package:admin_dvij/interfaces/entity_interface.dart';
import 'package:admin_dvij/users/admin_user/admin_user_class.dart';
import 'package:admin_dvij/users/admin_user/admin_users_list.dart';
import 'package:admin_dvij/users/admin_user/admins_list_screen.dart';
import 'package:admin_dvij/users/roles/admins_roles_class.dart';
import 'package:admin_dvij/users/simple_users/simple_users_list.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import '../../cities/cities_list_class.dart';
import '../../cities/city_class.dart';
import '../../constants/database_constants.dart';
import '../../constants/system_constants.dart';
import '../../database/database_class.dart';
import '../../database/image_uploader.dart';
import '../../design_elements/elements_of_design.dart';
import '../genders/gender_class.dart';

class SimpleUser extends IEntity{
  String uid;
  String email;
  String name;
  String lastName;
  String phone;
  String whatsapp;
  String telegram;
  String instagram;
  City city;
  DateTime birthDate;
  Gender gender;
  String avatar;
  DateTime registrationDate;

  SimpleUser({
    required this.uid,
    required this.email,
    required this.name,
    required this.lastName,
    required this.phone,
    required this.whatsapp,
    required this.telegram,
    required this.instagram,
    required this.city,
    required this.birthDate,
    required this.gender,
    required this.avatar,
    required this.registrationDate,
  });

  factory SimpleUser.empty() {
    return SimpleUser(
        uid: '',
        name: '',
        lastName: '',
        phone: '',
        email: '',
        birthDate: DateTime(2100),
        avatar: SystemConstants.defaultAvatar,
        registrationDate: DateTime(2100),
        city: City.empty(),
        gender: Gender(),
        whatsapp: '',
        telegram: '',
        instagram: '',

    );
  }

  factory SimpleUser.fromSnapshot(DataSnapshot snapshot){

    DateTime birthDate = DateTime.parse(snapshot.child(DatabaseConstants.birthDate).value.toString());
    DateTime regDate = DateTime.parse(snapshot.child(DatabaseConstants.registrationDate).value.toString());

    CitiesList cityList = CitiesList();
    City city = cityList.getEntityFromList(snapshot.child(DatabaseConstants.city).value.toString());

    return SimpleUser(
        uid: snapshot.child(DatabaseConstants.uid).value.toString(),
        name: snapshot.child(DatabaseConstants.name).value.toString(),
        lastName: snapshot.child(DatabaseConstants.lastName).value.toString(),
        phone: snapshot.child(DatabaseConstants.phone).value.toString(),
        email: snapshot.child(DatabaseConstants.email).value.toString(),
        birthDate: birthDate,
        avatar: snapshot.child(DatabaseConstants.avatar).value.toString(),
        registrationDate: regDate,
        city: city,
        gender: Gender.fromString(snapshot.child(DatabaseConstants.gender).value.toString()),
        whatsapp: snapshot.child(DatabaseConstants.whatsapp).value.toString(),
        telegram: snapshot.child(DatabaseConstants.telegram).value.toString(),
        instagram: snapshot.child(DatabaseConstants.instagram).value.toString()
    );
  }

  factory SimpleUser.fromJson(Map<String, dynamic> json) {

    CitiesList cityList = CitiesList();
    City city = cityList.getEntityFromList(json[DatabaseConstants.city] ?? '');

    return SimpleUser(
        uid: json[DatabaseConstants.uid] ?? '',
        name: json[DatabaseConstants.name] ?? '',
        lastName: json[DatabaseConstants.lastName] ?? '',
        phone: json[DatabaseConstants.phone] ?? '',
        email: json[DatabaseConstants.email] ?? '',
        birthDate: DateTime.parse(json[DatabaseConstants.birthDate] ?? '2100-01-01'),
        avatar: json[DatabaseConstants.avatar] ?? '',
        registrationDate: DateTime.parse(json[DatabaseConstants.registrationDate] ?? '2100-01-01'),
        city: city,
        gender: Gender.fromString(json[DatabaseConstants.gender] ?? ''),
        whatsapp: json[DatabaseConstants.whatsapp] ?? '',
        telegram: json[DatabaseConstants.telegram] ?? '',
        instagram: json[DatabaseConstants.instagram] ?? ''
    );
  }

  @override
  Future<String> deleteFromDb() async {
    DatabaseClass db = DatabaseClass();
    final ImageUploader imageUploader = ImageUploader();

    String path = '${SimpleUsersConstants.usersPath}/$uid/';

    String result = '';

    // Удаляем картинку
    await imageUploader.removeImage(
        folder: SimpleUsersConstants.usersPath,
        entityId: uid
    );

    if (!Platform.isWindows){
      result =  await db.deleteFromDb(path);
    } else {
      result = await db.deleteFromDbForWindows(path);
    }

    if (result == SystemConstants.successConst) {
      // Если удаление прошло успешно, удаляем из общего списка
      SimpleUsersList usersList = SimpleUsersList();
      usersList.deleteEntityFromDownloadedList(uid);
    }

    return result;
  }

  @override
  Map<String, dynamic> getMap() {
    return <String, dynamic> {
      DatabaseConstants.uid: uid,
      DatabaseConstants.name: name,
      DatabaseConstants.lastName: lastName,
      DatabaseConstants.phone: phone,
      DatabaseConstants.email: email,
      DatabaseConstants.birthDate: birthDate.toString(),
      DatabaseConstants.avatar: avatar,
      DatabaseConstants.registrationDate: registrationDate.toString(),
      DatabaseConstants.city: city.id,
      DatabaseConstants.gender: gender.toString(),
      DatabaseConstants.instagram: instagram,
      DatabaseConstants.whatsapp: whatsapp,
      DatabaseConstants.telegram: telegram,
    };
  }

  @override
  Future<String> publishToDb(File? imageFile) async{
    DatabaseClass db = DatabaseClass();
    final ImageUploader imageUploader = ImageUploader();

    // Переменная если будет загружаться изображение
    String? postedImageUrl;


    // Если Id не задан
    if (uid == '') {
      // Генерируем ID
      String? adminUid = db.generateKey();

      // Если ID по какой то причине не сгенерировался
      // генерируем вручную
      uid = adminUid ?? 'noUID_$email';
    }

    String path = '${SimpleUsersConstants.usersPath}/$uid/${SimpleUsersConstants.usersFolderInfo}';

    if (imageFile != null){

      postedImageUrl = await imageUploader.uploadImage(
        entityId: uid,
        folder: SimpleUsersConstants.usersPath,
        pickedFile: imageFile
      );

    }

    avatar = postedImageUrl ?? avatar;

    Map <String, dynamic> userData = getMap();

    String result = '';

    if (!Platform.isWindows){

      result = await db.publishToDB(path, userData);

    } else {

      result = await db.publishToDBForWindows(path, userData);

    }

    if (result == SystemConstants.successConst) {
      // Если результат успешный, добавляем в общий сохраненный список
      SimpleUsersList usersList = SimpleUsersList();
      usersList.addToCurrentDownloadedList(this);
    }

    return result;
  }

  Future<SimpleUser> getUserFromDownloadedList({required String uid, bool fromDb = false}) async{

    SimpleUsersList usersList = SimpleUsersList();

    if (fromDb) {
      await usersList.getListFromDb();
    }

    return usersList.getEntityFromList(uid);

  }


  String getFullName (){
    if (name.isNotEmpty && lastName.isNotEmpty){
      return '$name $lastName';
    } else if (name.isNotEmpty && lastName.isEmpty){
      return name;
    } else {
      return lastName;
    }
  }

  String getGender(){
    return gender.toString(needTranslate: true);
  }

  CircleAvatar getAvatar ({double size = 40}){
    return ElementsOfDesign.getAvatar(url: avatar, size: size);
  }

  AdminRoleClass getAdminRole (){
    AdminUsersListClass adminsListClass = AdminUsersListClass();

    return adminsListClass.getAdminRoleFromList(uid);

  }

  AdminUserClass createAdminUserFromSimpleUser(){
    return AdminUserClass(
        uid: uid,
        name: name,
        lastName: lastName,
        phone: phone,
        email: email,
        birthDate: birthDate,
        avatar: avatar,
        registrationDate: DateTime.now(),
        adminRole: AdminRoleClass(AdminRole.notChosen),
        city: city,
        gender: gender
    );
  }

}