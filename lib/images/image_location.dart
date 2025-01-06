enum ImageLocationEnum {
  admins,
  ads,
  events,
  places,
  promos,
  users,
  notChosen
}

class ImageLocation {
  ImageLocationEnum location;

  ImageLocation({this.location = ImageLocationEnum.notChosen});

  @override
  String toString() {
    switch (location) {
      case ImageLocationEnum.admins: return 'Администраторы';
      case ImageLocationEnum.ads: return 'Реклама';
      case ImageLocationEnum.events: return 'Мероприятия';
      case ImageLocationEnum.places: return 'Заведения';
      case ImageLocationEnum.promos: return 'Акции';
      case ImageLocationEnum.users: return 'Пользователи';
      case ImageLocationEnum.notChosen: return 'Не выбрано';
    }
  }

  String getPath () {
    switch (location) {
      case ImageLocationEnum.admins: return 'admins';
      case ImageLocationEnum.ads: return 'ads';
      case ImageLocationEnum.events: return 'events';
      case ImageLocationEnum.places: return 'places';
      case ImageLocationEnum.promos: return 'promos';
      case ImageLocationEnum.users: return 'users';
      case ImageLocationEnum.notChosen: return '';
    }
  }

}

