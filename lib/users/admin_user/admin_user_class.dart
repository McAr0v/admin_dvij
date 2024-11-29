import 'dart:io';
import 'package:admin_dvij/auth/auth_class.dart';
import 'package:admin_dvij/cities/cities_list_class.dart';
import 'package:admin_dvij/cities/city_class.dart';
import 'package:admin_dvij/constants/admins_constants.dart';
import 'package:admin_dvij/constants/database_constants.dart';
import 'package:admin_dvij/constants/system_constants.dart';
import 'package:admin_dvij/design_elements/elements_of_design.dart';
import 'package:admin_dvij/interfaces/entity_interface.dart';
import 'package:admin_dvij/system_methods/system_methods_class.dart';
import 'package:admin_dvij/users/admin_user/admin_users_list.dart';
import 'package:admin_dvij/users/genders/gender_class.dart';
import 'package:admin_dvij/users/roles/admins_roles_class.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import '../../database/database_class.dart';
import '../../database/image_uploader.dart';
import '../../design/app_colors.dart';

class AdminUserClass implements IEntity<AdminUserClass> {
  String uid;
  String name;
  String lastName;
  String phone;
  String email;
  DateTime birthDate;
  String avatar;
  DateTime registrationDate;
  AdminRoleClass adminRole;
  City city;
  Gender gender;

  AdminUserClass({
    required this.uid,
    required this.name,
    required this.lastName,
    required this.phone,
    required this.email,
    required this.birthDate,
    required this.avatar,
    required this.registrationDate,
    required this.adminRole,
    required this.city,
    required this.gender
  });

  static AdminUserClass? _currentUser;

  factory AdminUserClass.empty() {
    return AdminUserClass(
        uid: '',
        name: '',
        lastName: '',
        phone: '',
        email: '',
        birthDate: DateTime(2100),
        avatar: SystemConstants.defaultAvatar,
        registrationDate: DateTime(2100),
      adminRole: AdminRoleClass(AdminRole.notChosen),
      city: City.empty(),
      gender: Gender()
    );
  }

  factory AdminUserClass.fromSnapshot(DataSnapshot snapshot){

    DateTime birthDate = DateTime.parse(snapshot.child(DatabaseConstants.birthDate).value.toString());
    DateTime regDate = DateTime.parse(snapshot.child(DatabaseConstants.registrationDate).value.toString());

    CitiesList cityList = CitiesList();
    City city = cityList.getEntityFromList(snapshot.child(DatabaseConstants.city).value.toString());

    return AdminUserClass(
        uid: snapshot.child(DatabaseConstants.uid).value.toString(),
        name: snapshot.child(DatabaseConstants.name).value.toString(),
        lastName: snapshot.child(DatabaseConstants.lastName).value.toString(),
        phone: snapshot.child(DatabaseConstants.phone).value.toString(),
        email: snapshot.child(DatabaseConstants.email).value.toString(),
        birthDate: birthDate,
        avatar: snapshot.child(DatabaseConstants.avatar).value.toString(),
        registrationDate: regDate,
        adminRole: AdminRoleClass.fromString(snapshot.child(DatabaseConstants.adminRole).value.toString()),
        city: city,
      gender: Gender.fromString(snapshot.child(DatabaseConstants.gender).value.toString())
    );
  }

  factory AdminUserClass.fromJson(Map<String, dynamic> json) {

    CitiesList cityList = CitiesList();
    City city = cityList.getEntityFromList(json[DatabaseConstants.city] ?? '');

    return AdminUserClass(
      uid: json[DatabaseConstants.uid] ?? '',
      name: json[DatabaseConstants.name] ?? '',
      lastName: json[DatabaseConstants.lastName] ?? '',
      phone: json[DatabaseConstants.phone] ?? '',
      email: json[DatabaseConstants.email] ?? '',
      birthDate: DateTime.parse(json[DatabaseConstants.birthDate] ?? '2100-01-01'),
      avatar: json[DatabaseConstants.avatar] ?? '',
      registrationDate: DateTime.parse(json[DatabaseConstants.registrationDate] ?? '2100-01-01'),
      adminRole: AdminRoleClass.fromString(json[DatabaseConstants.adminRole] ?? ''),
      city: city,
      gender: Gender.fromString(json[DatabaseConstants.gender] ?? '')
    );
  }

  Future<String> signOut() async {
    AuthClass authClass = AuthClass();

    _currentUser = null;

    return await authClass.signOut();
  }

  Future<AdminUserClass> getCurrentUserFromDb() async {

    AdminUserClass currentAdmin = AdminUserClass.empty();

    AuthClass authClass = AuthClass();

    DatabaseClass database = DatabaseClass();

    User? currentUser = authClass.auth.currentUser;

    if (currentUser != null){
      String path = '${AdminConstants.adminsPath}/${currentUser.uid}/${AdminConstants.adminFolderInfo}';

      // Подгрузка если платформа не Windows
      if (!Platform.isWindows){
        DataSnapshot? snapshot = await database.getInfoFromDb(path);

        if (snapshot != null && snapshot.exists) {
          currentAdmin = AdminUserClass.fromSnapshot(snapshot);
        }

      } else {

        // Подгрузка если Windows
        dynamic data = await database.getInfoFromDbForWindows(path);

        if (data != null){
          currentAdmin = AdminUserClass.fromJson(data);
        }
      }
    }

    _currentUser = currentAdmin;

    return _currentUser ?? AdminUserClass.empty();
  }

  Future<AdminUserClass> getUserFromDownloadedList({required String uid, bool fromDb = false}) async{

    AdminUsersListClass adminUsersListClass = AdminUsersListClass();

    if (fromDb) {
      await adminUsersListClass.getListFromDb();
    }

    return adminUsersListClass.getEntityFromList(uid);

  }

  Future<AdminUserClass> getCurrentUser({bool fromDb = false}) async{

    if (_currentUser == null || _currentUser!.uid.isEmpty || fromDb) {
      await getCurrentUserFromDb();
    }

    return _currentUser ?? AdminUserClass.empty();
  }

  void setCurrentUser(AdminUserClass user){
    _currentUser = user;
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

  @override
  Future<String> deleteFromDb() async{
    DatabaseClass db = DatabaseClass();
    final ImageUploader imageUploader = ImageUploader();

    String path = '${AdminConstants.adminsPath}/$uid/';

    String result = '';

    // Удаляем картинку
    await imageUploader.removeImage(
      folder: AdminConstants.adminsPath,
      entityId: uid
    );

    if (!Platform.isWindows){
      result =  await db.deleteFromDb(path);
    } else {
      result = await db.deleteFromDbForWindows(path);
    }

    if (result == SystemConstants.successConst) {
      // Если удаление прошло успешно, удаляем из общего списка
      AdminUsersListClass adminsList = AdminUsersListClass();
      adminsList.deleteEntityFromDownloadedList(uid);
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
      DatabaseConstants.adminRole: adminRole.toString(),
      DatabaseConstants.city: city.id,
      DatabaseConstants.gender: gender.toString()
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

    String path = '${AdminConstants.adminsPath}/$uid/${AdminConstants.adminFolderInfo}';

    if (imageFile != null){

      postedImageUrl = await imageUploader.uploadImage(
        entityId: uid,
        pickedFile: imageFile,
        folder: AdminConstants.adminsPath
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
      AdminUsersListClass adminsList = AdminUsersListClass();
      adminsList.addToCurrentDownloadedList(this);
    }

    return result;
  }

  String calculateExperienceTime() {
    SystemMethodsClass systemMethods = SystemMethodsClass();
    return systemMethods.calculateExperienceTime(registrationDate);

  }



  String calculateYears() {
    SystemMethodsClass sm = SystemMethodsClass();

    return sm.calculateYears(birthDate);

  }


  String formatBirthDateTime() {

    SystemMethodsClass sm = SystemMethodsClass();

    return sm.formatDateTimeToHumanView(birthDate);

  }


  CircleAvatar getAvatar ({double size = 40}){
    return ElementsOfDesign.getAvatar(url: avatar, size: size);
  }

  Widget getInfoWidgetForProfile ({File? imageFile, required BuildContext context}){
    return  Row(
      children: [

        CircleAvatar(
          radius: 40,
          backgroundColor: AppColors.greyOnBackground,
          child: ClipOval(
            child: imageFile != null
                ? Image.file(
              imageFile,
              fit: BoxFit.cover,
              width: 100,
              height: 100,
            )
                : FadeInImage(
              placeholder: const AssetImage(SystemConstants.defaultImagePath),
              image: NetworkImage(avatar),
              fit: BoxFit.cover,
              width: 100,
              height: 100,
              imageErrorBuilder: (context, error, stackTrace) {
                return Image.asset(
                  SystemConstants.defaultImagePath, // Изображение ошибки
                  fit: BoxFit.cover,
                  width: 100,
                  height: 100,
                );
              },
            ),
          ),
        ),

        if (uid.isNotEmpty) const SizedBox(width: 20,),

        if (uid.isNotEmpty) Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(getFullName()),
                Text(
                  '${calculateYears()}, ${adminRole.getNameOrDescOfRole(true)}',
                  style: Theme.of(context).textTheme.labelMedium!.copyWith(color: AppColors.greyText),
                ),

                Row(
                  children: [
                    Text(
                      AdminConstants.inTeamSince,
                      style: Theme.of(context).textTheme.labelSmall!.copyWith(color: AppColors.greyText),
                    ),
                    Text(
                      calculateExperienceTime(),
                      style: Theme.of(context).textTheme.labelSmall!.copyWith(color: Colors.green),
                    ),
                  ],
                ),

              ],
            )
        ),

      ],
    );
  }

}