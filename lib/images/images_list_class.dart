import 'package:admin_dvij/ads/ads_list_class.dart';
import 'package:admin_dvij/database/image_uploader.dart';
import 'package:admin_dvij/events/events_list_class.dart';
import 'package:admin_dvij/images/image_from_db.dart';
import 'package:admin_dvij/images/image_location.dart';
import 'package:admin_dvij/interfaces/list_entities_interface.dart';
import 'package:admin_dvij/places/places_list_class.dart';
import 'package:admin_dvij/promos/promos_list_class.dart';
import 'package:admin_dvij/users/admin_user/admin_users_list.dart';
import 'package:admin_dvij/users/simple_users/simple_users_list.dart';

class ImagesList implements IEntitiesList<ImageFromDb> {

  static List<ImageFromDb> _currentImagesList = [];

  @override
  void addToCurrentDownloadedList(ImageFromDb entity) {
    // Проверяем, есть ли элемент с таким id
    int index = _currentImagesList.indexWhere((c) => c.id == entity.id && c.location.location == entity.location.location);



    if (index != -1) {
      // Если элемент с таким id уже существует, заменяем его
      _currentImagesList[index] = entity;
    } else {
      // Если элемет с таким id не найден, добавляем новый
      _currentImagesList.add(entity);
    }
  }

  @override
  bool checkEntityNameInList(String entity) {
    if (_currentImagesList.any((element) => element.id.toLowerCase() == entity.toLowerCase())) {
      return false;
    } else {
      return true;
    }
  }

  @override
  void deleteEntityFromDownloadedList(String id) {

    // Так как id у пользователя и админа могут быть одинаковы
    // Мне нужно передать id и location в одном String
    // Для точного определения, какую сущность нужно удалить из списка

    // Для этого передаю сюда, объеденив id и location
    // а в методе разделяю обратно

    List<String> parts = id.split('_');

    String idFromId = parts[0];
    String location = parts[1];

    if (_currentImagesList.isNotEmpty){
      _currentImagesList.removeWhere(
              (image) =>
                  // Нужно, чтобы совпадал id
                  image.id == idFromId
                  // и Location
                  && image.location.location == ImageLocation.fromString(folderName: location).location
      );
    }
  }

  @override
  Future<List<ImageFromDb>> getDownloadedList({bool fromDb = false}) async {
    if (_currentImagesList.isEmpty || fromDb) {
      await getListFromDb();
    }
    return _currentImagesList;
  }

  Future<List<ImageFromDb>> getNeededList({
    bool fromDb = false,
    required bool isActive,
    required ImageLocation location,
    required String searchingText,
  }) async {

    List<ImageFromDb> returnedList = [];
    List<ImageFromDb> inActiveList = [];

    if (_currentImagesList.isEmpty || fromDb) {
      await getListFromDb();
    }

    // Если нужны все изображения
    if (isActive){
      for (ImageFromDb image in _currentImagesList){
        if (location.location == ImageLocationEnum.notChosen){
          returnedList.add(image);
        } else if (image.checkLocation(locationFromFilter: location)){
          returnedList.add(image);
        }
      }
    }
    // Если нужны не активные изображения
    else {
      // Фильтруем все неактивные изображения из основного списка
      // в отдельную переменную

      inActiveList = await getUnusedImages(fromDb: fromDb);

      for (ImageFromDb image in inActiveList){
        if (location.location == ImageLocationEnum.notChosen){
          returnedList.add(image);
        } else if (image.checkLocation(locationFromFilter: location)){
          returnedList.add(image);
        }
      }

    }

    if (searchingText.isNotEmpty){
      returnedList = returnedList
          .where((image) =>
          image.id.toLowerCase().contains(searchingText.toLowerCase()) ||
          image.location.toString().toLowerCase().contains(searchingText.toLowerCase()) ||
          image.getEntityName().toLowerCase().contains(searchingText.toLowerCase())
      ).toList();
    }

    returnedList.sortByLocation(true);

    return returnedList;
  }

  Future<List<ImageFromDb>> getUnusedImages({bool fromDb = false}) async {

    List<ImageFromDb> returnedList = [];

    AdminUsersListClass adminsListClass = AdminUsersListClass();
    AdsList adsListClass = AdsList();
    EventsListClass eventsListClass = EventsListClass();
    PlacesList placesListClass = PlacesList();
    PromosListClass promosListClass = PromosListClass();
    SimpleUsersList simpleUsersList = SimpleUsersList();


    if (_currentImagesList.isEmpty || fromDb) {
      await getListFromDb();
    }

    if (_currentImagesList.isNotEmpty){
      returnedList.addAll(await adminsListClass.searchUnusedImages(imagesList: _currentImagesList));
      returnedList.addAll(await adsListClass.searchUnusedImages(imagesList: _currentImagesList));
      returnedList.addAll(await eventsListClass.searchUnusedImages(imagesList: _currentImagesList));
      returnedList.addAll(await placesListClass.searchUnusedImages(imagesList: _currentImagesList));
      returnedList.addAll(await promosListClass.searchUnusedImages(imagesList: _currentImagesList));
      returnedList.addAll(await simpleUsersList.searchUnusedImages(imagesList: _currentImagesList));
    }

    return returnedList;
  }

  @override
  ImageFromDb getEntityFromList(String id) {
    ImageFromDb returnedEntity = ImageFromDb.empty();

    if (_currentImagesList.isNotEmpty) {
      for (ImageFromDb entity in _currentImagesList) {
        if (entity.id == id) {
          returnedEntity = entity;
          break;
        }
      }
    }
    return returnedEntity;
  }

  @override
  Future<List<ImageFromDb>> getListFromDb() async{
    List <ImageFromDb> returnedImages = [];

    ImageUploader im = ImageUploader();

    List<ImageFromDb> adminsImagesList = await im.getImageInPath(ImageLocation(location: ImageLocationEnum.admins));
    List<ImageFromDb> adsImagesList = await im.getImageInPath(ImageLocation(location: ImageLocationEnum.ads));
    List<ImageFromDb> eventsImagesList = await im.getImageInPath(ImageLocation(location: ImageLocationEnum.events));
    List<ImageFromDb> placesImagesList = await im.getImageInPath(ImageLocation(location: ImageLocationEnum.places));
    List<ImageFromDb> promosImagesList = await im.getImageInPath(ImageLocation(location: ImageLocationEnum.promos));
    List<ImageFromDb> usersImagesList = await im.getImageInPath(ImageLocation(location: ImageLocationEnum.users));

    returnedImages.addAll(adminsImagesList);
    returnedImages.addAll(adsImagesList);
    returnedImages.addAll(eventsImagesList);
    returnedImages.addAll(placesImagesList);
    returnedImages.addAll(promosImagesList);
    returnedImages.addAll(usersImagesList);

    // Устанавливаем подгруженный список в нашу доступную переменную
    setDownloadedList(returnedImages);

    return _currentImagesList;
  }

  @override
  List<ImageFromDb> searchElementInList(String query) {
    List<ImageFromDb> toReturn = _currentImagesList;

    toReturn = toReturn
        .where((image) =>
    image.id.toLowerCase().contains(query.toLowerCase())
        || image.location.toString().toLowerCase().contains(query.toLowerCase())
    ).toList();

    return toReturn;
  }

  @override
  void setDownloadedList(List<ImageFromDb> list) {
    _currentImagesList = [];
    _currentImagesList = list;
  }

}

extension SortSimpleUsersListExtension on List<ImageFromDb> {

  void sortByLocation(bool order) {
    if (order) {
      sort((a, b) => a.location.toString().compareTo(b.location.toString()));
    } else {
      sort((a, b) => b.location.toString().compareTo(a.location.toString()));
    }
  }

}