import 'package:admin_dvij/dates/once_date.dart';

class IrregularDate {
  List<OnceDate> dates;

  IrregularDate({required this.dates});

  factory IrregularDate.empty(){
    return IrregularDate(dates: []);
  }

  /// Метод для преобразования JSON-строки в объект IrregularDate
  factory IrregularDate.fromJson({required String json}) {

    if (json.isNotEmpty){

      if (json.startsWith('[') && json.endsWith(']')) {
        // Удаляем квадратные скобки из строки
        final String trimmedJson = json.substring(1, json.length - 1);

        // Разделяем строки по символу '_', чтобы получить список отдельных OnceDate
        final List<String> dateStrings = trimmedJson.split('_');

        // Преобразуем каждую строку в объект OnceDate
        final List<OnceDate> parsedDates = dateStrings.map((dateString) {
          return OnceDate.fromJson(jsonString: dateString);
        }).toList();

        IrregularDate returnedDates = IrregularDate(dates: parsedDates);

        // Сортируем даты
        returnedDates.sortDates();

        // Возвращаем объект IrregularDate
        return returnedDates;
      }
    }

    return IrregularDate.empty();

  }

  /// Метод для преобразования объекта IrregularDate в JSON-строку
  String toJson() {
    // Проверяем, если список пуст, возвращаем пустой JSON-массив
    if (dates.isEmpty) {
      return '';
    }

    // Создаем строку вручную, избегая добавления '_' после последнего элемента
    final StringBuffer buffer = StringBuffer('[');

    for (int i = 0; i < dates.length; i++) {
      buffer.write(dates[i].toJsonString());
      if (i < dates.length - 1) {
        buffer.write('_'); // Добавляем '_' только между элементами
      }
    }

    buffer.write(']');
    return buffer.toString();
  }

  bool isToday() {
    bool result = false;

    for (OnceDate date in dates){
      if (date.isToday()) {
        result = true;
        break;
      }
    }
    return result;
  }

  bool isOngoing(){
    bool result = false;

    for (OnceDate date in dates){
      if (date.isOngoing()){
        result = true;
        break;
      }
    }
    return result;
  }

  bool isFinished(){
    bool result = true;

    for (OnceDate date in dates){
      if (!date.isFinished()){
        result = false;
        break;
      }
    }

    return result;

  }

  // Метод сортировки
  void sortDates() {
    dates.sort((a, b) {
      // Сравниваем по времени начала
      return a.startDateTime.compareTo(b.startDateTime);
    });
  }


}