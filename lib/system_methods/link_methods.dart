import 'package:url_launcher/url_launcher.dart';

import '../constants/system_constants.dart';

class LinkMethods {

  String extractInstagramUsername(String input) {
    // Удаляем начальные и конечные пробелы
    input = input.trim();

    // Проверка на полную ссылку
    final fullUrlPattern = RegExp(r'^https?://(www\.)?instagram\.com/([A-Za-z0-9_.]+)');
    final match = fullUrlPattern.firstMatch(input);
    if (match != null) {
      return match.group(2)!; // Возвращаем имя пользователя из URL
    }

    // Если начинается с '@', удаляем '@'
    if (input.startsWith('@')) {
      input = input.substring(1);
    }

    // Проверка, что это корректное имя пользователя
    final usernamePattern = RegExp(r'^[A-Za-z0-9_.]+$');
    if (usernamePattern.hasMatch(input)) {
      return input; // Возвращаем имя пользователя
    }

    // Если ничего не подошло, возвращаем пустую строку
    return '';
  }

  String extractTelegramUsername(String input) {
    // Удаляем начальные и конечные пробелы
    input = input.trim();

    // Проверка на полный URL
    final fullUrlPattern = RegExp(r'^https?://(www\.)?t\.me/([A-Za-z0-9_]+)', caseSensitive: false);
    final shortUrlPattern = RegExp(r'^t\.me/([A-Za-z0-9_]+)', caseSensitive: false);
    final matchFullUrl = fullUrlPattern.firstMatch(input);
    final matchShortUrl = shortUrlPattern.firstMatch(input);

    if (matchFullUrl != null) {
      return matchFullUrl.group(2)!; // Возвращаем имя пользователя из полного URL
    } else if (matchShortUrl != null) {
      return matchShortUrl.group(1)!; // Возвращаем имя пользователя из короткого URL
    }

    // Если начинается с '@', удаляем '@'
    if (input.startsWith('@')) {
      input = input.substring(1);
    }

    // Проверка, что это корректное имя пользователя
    final usernamePattern = RegExp(r'^[A-Za-z0-9_]+$');
    if (usernamePattern.hasMatch(input)) {
      return input; // Возвращаем имя пользователя
    }

    // Если ничего не подошло, возвращаем пустую строку
    return '';
  }

  String replaceWhatsappFirstNumberForLink(String input){
    // Преобразование номера, начинающегося с 8, в международный формат
    if (input.startsWith('8')) {
      return input.replaceFirst('8', '7');
    } else {
      return input;
    }
  }

  Future<void> openUrl(String insertString, UrlPathEnum pathEnum) async {
    String path = '';

    switch (pathEnum) {
      case UrlPathEnum.instagram:
        path = '${SystemConstants.pathToInstagram}${insertString.toLowerCase()}/';
        break;
      case UrlPathEnum.telegram:
        path = '${SystemConstants.pathToTelegram}${insertString.toLowerCase()}/';
        break;
      case UrlPathEnum.whatsapp:
        path = '${SystemConstants.pathToWhatsapp}$insertString/';
        break;
      case UrlPathEnum.phone:
        path = '${SystemConstants.pathToTel}$insertString';
        break;
      case UrlPathEnum.web:
        path = insertString;
    }

    launchUrl(Uri.parse(path), mode: LaunchMode.externalApplication);

  }

  String extractWhatsAppNumber(String input) {
    // Удаляем начальные и конечные пробелы
    input = input.trim();

    // Проверка на ссылку формата wa.me
    final waLinkPattern = RegExp(r'(https?://)?wa\.me/(\d+)', caseSensitive: false);
    final matchLink = waLinkPattern.firstMatch(input);
    if (matchLink != null) {
      input = matchLink.group(2)!; // Возвращаем номер из ссылки
    }

    // Удаляем все нецифровые символы
    input = input.replaceAll(RegExp(r'[^\d+]'), '');

    // Если номер начинается с '+', удаляем его для стандартизации
    if (input.startsWith('+')) {
      input = input.substring(1);
    }

    if (input.startsWith('7')) {
      return input.replaceFirst('7', '8');
    }

    // Проверка валидности номера (должно быть только цифры и длина от 10 до 15)
    final numberPattern = RegExp(r'^\d{10,15}$');
    if (numberPattern.hasMatch(input)) {
      return input;
    }

    // Если номер некорректный, возвращаем пустую строку
    return '';
  }

}

enum UrlPathEnum {
  instagram,
  telegram,
  whatsapp,
  phone,
  web
}