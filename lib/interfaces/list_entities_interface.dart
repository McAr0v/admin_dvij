abstract class IEntitiesList<T> {

  /// Метод перезаписи скаченного списка сущностей
  /// новыми значениями
  void setDownloadedList (List<T> list);

  /// Метод поиска сущностей по параметру
  List<T> searchElementInList(String query);

  /// Метод получения списка сущностей.
  /// <br> 1 - Если fromDb - автоматически запустит метод getListFromDb для подкачки с БД
  /// <br> 2 - Если скачанный список пустой, так же запустит метод для подкачки с БД
  /// <br> 3 - Если !fromDb и есть скачанный список, то вернет скачанный список
  Future<List<T>> getDownloadedList ({bool fromDb = false});

  /// Метод получения списка сущностей из БД.
  /// <br>
  /// <br> 1 - АВТОМАТИЧЕСКИ ОБНОВЛЯЕТ СКАЧЕННЫЙ СПИСОК СУЩНОСТЕЙ
  /// <br> 2 - АВТОМАТИЧЕСКИ СОРТИРУЕТ СКАЧЕННЫЙ СПИСОК СУЩНОСТЕЙ
  /// <br> 3 - СОДЕРЖИТ ОТДЕЛЬНЫЕ МЕТОДЫ ДЛЯ WINDOWS И ДРУГИХ ПЛАТФОРМ
  Future<List<T>> getListFromDb ();

  /// Метод проверки, содержится ли элемент по имени в скачанном списке
  bool checkEntityNameInList(String entity);

  /// Метод добавления или замены сущности в скачанном списке
  /// <br> 1 - Если элемент содержится в списке, он обновится новой сущостью
  /// <br> 2 - Если элемента такого нет, то добавится новый
  void addToCurrentDownloadedList(T entity);

  /// Метод удаления сущности из скачанного списка
  void deleteEntityFromDownloadedList(String id);

  /// Метод поиска сущности из скачанного списка
  T getEntityFromList(String id);



}