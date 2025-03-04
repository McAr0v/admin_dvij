import 'dart:io';

abstract class IEntity <T> {

  /// Метод публикации в базу данных.
  /// Поддерживает публикацию Windows приложений и всех остальных
  /// <br><br>
  /// Автоматически обновляет общий список сущности опубликованной сущностью
  Future<String> publishToDb(File? imageFile);

  /// Метод удаления из базы данных.
  /// Поддерживает удаление в Windows приложениях и остальных
  /// <br><br>
  /// Автоматически удаляет из общего списка сущностей удаляемую сущность
  Future<String> deleteFromDb();

  /// Метод генерации ключ-значение для публикации в базу данных
  Map<String, dynamic> getMap ();

}