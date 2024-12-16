import 'dart:io';
import 'package:admin_dvij/constants/places_constants.dart';
import 'package:admin_dvij/constants/simple_users_constants.dart';
import 'package:admin_dvij/interfaces/entity_interface.dart';
import 'package:admin_dvij/places/place_admin/place_admin_class.dart';
import 'package:admin_dvij/users/admin_user/admin_user_class.dart';
import 'package:admin_dvij/users/admin_user/admin_users_list.dart';
import 'package:admin_dvij/users/roles/admins_roles_class.dart';
import 'package:admin_dvij/users/simple_users/simple_users_list.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../cities/cities_list_class.dart';
import '../../cities/city_class.dart';
import '../../constants/admins_constants.dart';
import '../../constants/database_constants.dart';
import '../../constants/system_constants.dart';
import '../../database/database_class.dart';
import '../../database/image_uploader.dart';
import '../../design/app_colors.dart';
import '../../design_elements/elements_of_design.dart';
import '../../system_methods/system_methods_class.dart';
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
  List<PlaceAdmin> placesList;

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
    required this.placesList
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
        placesList: []

    );
  }

  factory SimpleUser.fromSnapshot(DataSnapshot snapshot){

    DataSnapshot infoFolder = snapshot.child(SimpleUsersConstants.usersFolderInfo);
    DataSnapshot myPlacesFolder = snapshot.child(SimpleUsersConstants.usersMyPlacesFolder);

    DateTime birthDate = DateTime.parse(infoFolder.child(DatabaseConstants.birthDate).value.toString());
    DateTime regDate = DateTime.parse(infoFolder.child(DatabaseConstants.registrationDate).value.toString());

    List<PlaceAdmin> myPlaces = PlaceAdmin.empty().getPlacesListFromSnapshot(myPlacesFolder);

    CitiesList cityList = CitiesList();
    City city = cityList.getEntityFromList(infoFolder.child(DatabaseConstants.city).value.toString());

    return SimpleUser(
        uid: infoFolder.child(DatabaseConstants.uid).value.toString(),
        name: infoFolder.child(DatabaseConstants.name).value.toString(),
        lastName: infoFolder.child(DatabaseConstants.lastName).value.toString(),
        phone: infoFolder.child(DatabaseConstants.phone).value.toString(),
        email: infoFolder.child(DatabaseConstants.email).value.toString(),
        birthDate: birthDate,
        avatar: infoFolder.child(DatabaseConstants.avatar).value.toString(),
        registrationDate: regDate,
        city: city,
        gender: Gender.fromString(infoFolder.child(DatabaseConstants.gender).value.toString()),
        whatsapp: infoFolder.child(DatabaseConstants.whatsapp).value.toString(),
        telegram: infoFolder.child(DatabaseConstants.telegram).value.toString(),
        instagram: infoFolder.child(DatabaseConstants.instagram).value.toString(),
        placesList: myPlaces
    );
  }

  factory SimpleUser.fromJson(Map<String, dynamic> json) {

    // DataSnapshot infoFolder = snapshot.child(SimpleUsersConstants.usersFolderInfo);

    Map<String, dynamic> infoFolder = json[SimpleUsersConstants.usersFolderInfo];
    Map<String, dynamic> myPlacesFolder = json[SimpleUsersConstants.usersMyPlacesFolder];

    List<PlaceAdmin> myPlaces = PlaceAdmin.empty().getPlacesListFromJson(myPlacesFolder);

    CitiesList cityList = CitiesList();
    City city = cityList.getEntityFromList(infoFolder[DatabaseConstants.city] ?? '');

    return SimpleUser(
        uid: infoFolder[DatabaseConstants.uid] ?? '',
        name: infoFolder[DatabaseConstants.name] ?? '',
        lastName: infoFolder[DatabaseConstants.lastName] ?? '',
        phone: infoFolder[DatabaseConstants.phone] ?? '',
        email: infoFolder[DatabaseConstants.email] ?? '',
        birthDate: DateTime.parse(infoFolder[DatabaseConstants.birthDate] ?? '2100-01-01'),
        avatar: infoFolder[DatabaseConstants.avatar] ?? '',
        registrationDate: DateTime.parse(infoFolder[DatabaseConstants.registrationDate] ?? '2100-01-01'),
        city: city,
        gender: Gender.fromString(infoFolder[DatabaseConstants.gender] ?? ''),
        whatsapp: infoFolder[DatabaseConstants.whatsapp] ?? '',
        telegram: infoFolder[DatabaseConstants.telegram] ?? '',
        instagram: infoFolder[DatabaseConstants.instagram] ?? '',
        placesList: myPlaces
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

  String formatBirthDateTime() {

    SystemMethodsClass sm = SystemMethodsClass();

    return sm.formatDateTimeToHumanView(birthDate);

  }

  String calculateYears() {
    SystemMethodsClass sm = SystemMethodsClass();

    return sm.calculateYears(birthDate);

  }

  bool checkAdminRoleInUser(String placeId){
    for (PlaceAdmin admin in placesList){
      if (admin.placeId == placeId){
        return true;
      }
    }
    return false;
  }

  Future<String> deletePlaceRoleFromUser(String placeId) async{

    PlaceAdmin tempAdmin = PlaceAdmin.empty();

    String result = '';

    for (PlaceAdmin admin in placesList){
      if (admin.placeId == placeId){
        tempAdmin = admin;
        break;
      }
    }

    if (tempAdmin.placeId.isNotEmpty){
      result = await tempAdmin.deleteFromDb(uid);
    }

    if (result == SystemConstants.successConst) {
      deletePlaceFromMyPlacesList(placeId);
    }

    return result;

  }

  void deletePlaceFromMyPlacesList(String placeId){

    if (placesList.isNotEmpty){
      placesList.removeWhere( (admin) => admin.placeId == placeId);
    }

  }

  Future<String> publishPlaceRoleForCurrentUser (PlaceAdmin placeAdmin) async {

    String result = '';

    result = await placeAdmin.publishToDb(uid);

    if (result == SystemConstants.successConst){
      // Проверяем, есть ли элемент с таким id
      int index = placesList.indexWhere((c) => c.placeId == placeAdmin.placeId);

      if (index != -1) {
        // Если элемент с таким id уже существует, заменяем его
        placesList[index] = placeAdmin;
      } else {
        // Если элемет с таким id не найден, добавляем новый
        placesList.add(placeAdmin);
      }
    }

    return result;

  }

  Widget getInfoWidgetForProfile ({File? imageFile, required BuildContext context}){
    return  Row(
      children: [

        CircleAvatar(
          radius: 40,
          backgroundColor: AppColors.greyOnBackground,
          child: ClipOval(
            child: imageFile != null
                ? ElementsOfDesign.getImageFromFile(image: imageFile)
                : ElementsOfDesign.getImageFromUrl(imageUrl: avatar),
          ),
        ),

        if (uid.isNotEmpty) const SizedBox(width: 20,),

        if (uid.isNotEmpty) Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(getFullName()),
                Text(
                  calculateYears(),
                  style: Theme.of(context).textTheme.labelMedium!.copyWith(color: AppColors.greyText),
                ),
              ],
            )
        ),

      ],
    );
  }

  Widget getUserCardInList ({
    required BuildContext context,
    required VoidCallback onTap,
    required VoidCallback createAdminFunc,
    required AdminUserClass currentAdmin
  }){

    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: AppColors.greyOnBackground,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [

              getAvatar(size: Platform.isWindows || Platform.isMacOS ? 40 : 30),

              const SizedBox(width: 20,),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(getFullName()),
                        if (getAdminRole().adminRole != AdminRole.notChosen) const SizedBox(width: 10,),
                        if (getAdminRole().adminRole != AdminRole.notChosen) const Icon(FontAwesomeIcons.circleCheck, size: 15, color: Colors.green,),
                      ],
                    ),
                    if (currentAdmin.uid == uid) Text(AdminConstants.itsYou, style: Theme.of(context).textTheme.labelMedium!.copyWith(color: Colors.green),),
                    const SizedBox(height: 5,),
                    Text(email, style: Theme.of(context).textTheme.labelMedium!.copyWith(color: AppColors.greyText),),
                    Text(
                      getAdminRole().getNameOrDescOfRole(true),
                      style: Theme.of(context).textTheme.labelMedium!.copyWith(color: AppColors.greyText),
                    ),
                    Text(
                      'Моих заведений - ${placesList.length.toString()}',
                      style: Theme.of(context).textTheme.labelMedium!.copyWith(color: AppColors.greyText),
                    ),
                  ],
                ),
              ),

              if (getAdminRole().adminRole == AdminRole.notChosen) IconButton(
                  onPressed: createAdminFunc,
                  icon: const Icon(
                    FontAwesomeIcons.userGear,
                    size: 15,
                    color: AppColors.brandColor,
                  )
              ),
            ],
          ),
        ),
      ),
    );
  }



}