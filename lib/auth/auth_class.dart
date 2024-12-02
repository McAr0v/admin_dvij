import 'package:admin_dvij/constants/system_constants.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthClass{

  FirebaseAuth auth = FirebaseAuth.instance;

  Future<String?> createUserWithEmailAndPassword(String email, String password) async {
    try{
      final credential = await auth.createUserWithEmailAndPassword(email: email, password: password);

      User? user = credential.user;

      return user?.uid;
    } on FirebaseAuthException catch (e) {
      return e.code;
    }
  }

  Future<String?> getIdToken() async {
    if (auth.currentUser != null) {
      return await auth.currentUser!.getIdToken();
    } else {
      return null;
    }

  }

  Future<String> signOut() async{
    try {
      await auth.signOut();

      return SystemConstants.successConst;

    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> signInWithEmailAndPassword(String emailAddress, String password) async {
    try {
      final credential = await auth.signInWithEmailAndPassword(
        email: emailAddress,
        password: password,
      );

      // и возвращаем uid
      return credential.user?.uid;

    } on FirebaseAuthException catch (e) {

      return e.code;

    } catch (e) {
      return null;
    }
  }

  String getUserId(){
    return auth.currentUser!.uid;
  }

  // Метод проверки на ошибки при авторизации
  bool checkAnswerOnError(String message) {
    // Убираем префикс 'auth/' (если он есть)
    String errorCode = message.startsWith('auth/') ? message.substring(5) : message;

    switch (errorCode) {
      case 'admin-restricted-operation':
      case 'argument-error':
      case 'app-not-authorized':
      case 'app-not-installed':
      case 'captcha-check-failed':
      case 'code-expired':
      case 'cordova-not-ready':
      case 'cors-unsupported':
      case 'credential-already-in-use':
      case 'custom-token-mismatch':
      case 'requires-recent-login':
      case 'dependent-sdk-initialized-before-auth':
      case 'dynamic-link-not-activated':
      case 'email-change-needs-verification':
      case 'email-already-in-use':
      case 'emulator-config-failed':
      case 'expired-action-code':
      case 'cancelled-popup-request':
      case 'internal-error':
      case 'invalid-api-key':
      case 'invalid-app-credential':
      case 'invalid-app-id':
      case 'invalid-user-token':
      case 'invalid-auth-event':
      case 'invalid-cert-hash':
      case 'invalid-verification-code':
      case 'invalid-continue-uri':
      case 'invalid-cordova-configuration':
      case 'invalid-custom-token':
      case 'invalid-dynamic-link-domain':
      case 'invalid-email':
      case 'invalid-emulator-scheme':
      case 'invalid-credential':
      case 'invalid-message-payload':
      case 'invalid-multi-factor-session':
      case 'invalid-oauth-client-id':
      case 'invalid-oauth-provider':
      case 'invalid-action-code':
      case 'unauthorized-domain':
      case 'wrong-password':
      case 'invalid-persistence-type':
      case 'invalid-phone-number':
      case 'invalid-provider-id':
      case 'invalid-recipient-email':
      case 'invalid-sender':
      case 'invalid-verification-id':
      case 'invalid-tenant-id':
      case 'multi-factor-info-not-found':
      case 'multi-factor-auth-required':
      case 'missing-android-pkg-name':
      case 'missing-app-credential':
      case 'auth-domain-config-required':
      case 'missing-verification-code':
      case 'missing-continue-uri':
      case 'missing-iframe-start':
      case 'missing-ios-bundle-id':
      case 'missing-or-invalid-nonce':
      case 'missing-multi-factor-info':
      case 'missing-multi-factor-session':
      case 'missing-phone-number':
      case 'missing-verification-id':
      case 'app-deleted':
      case 'account-exists-with-different-credential':
      case 'network-request-failed':
      case 'null-user':
      case 'no-auth-event':
      case 'no-such-provider':
      case 'operation-not-allowed':
      case 'operation-not-supported-in-this-environment':
      case 'popup-blocked':
      case 'popup-closed-by-user':
      case 'provider-already-linked':
      case 'quota-exceeded':
      case 'redirect-cancelled-by-user':
      case 'redirect-operation-pending':
      case 'rejected-credential':
      case 'second-factor-already-in-use':
      case 'maximum-second-factor-count-exceeded':
      case 'tenant-id-mismatch':
      case 'timeout':
      case 'user-token-expired':
      case 'too-many-requests':
      case 'unauthorized-continue-uri':
      case 'unsupported-first-factor':
      case 'unsupported-persistence-type':
      case 'unsupported-tenant-operation':
      case 'unverified-email':
      case 'user-cancelled':
      case 'user-not-found':
      case 'user-disabled':
      case 'user-mismatch':
      case 'user-signed-out':
      case 'weak-password':
      case 'web-storage-unsupported':
      case 'already-initialized':
      case 'recaptcha-not-enabled':
      case 'missing-recaptcha-token':
      case 'invalid-recaptcha-token':
      case 'invalid-recaptcha-action':
      case 'missing-client-type':
      case 'missing-recaptcha-version':
      case 'invalid-recaptcha-version':
      case 'invalid-req-type':
        return false;
      default:
        return true;
    }
  }

  // Метод расшифровки ошибки при авторизации

  String getErrorTranslation(String message) {
    // Убираем префикс 'auth/' (если он есть)
    String errorCode = message.startsWith('auth/') ? message.substring(5) : message;

    switch (errorCode) {
      case 'admin-restricted-operation':
        return 'Операция ограничена для администратора.';
      case 'argument-error':
        return 'Передан недопустимый аргумент.';
      case 'app-not-authorized':
        return 'Приложение не авторизовано для выполнения этой операции.';
      case 'app-not-installed':
        return 'Приложение не установлено на устройстве.';
      case 'captcha-check-failed':
        return 'Проверка капчи не прошла.';
      case 'code-expired':
        return 'Код истек.';
      case 'cordova-not-ready':
        return 'Приложение не готово для работы с Cordova.';
      case 'cors-unsupported':
        return 'CORS не поддерживается.';
      case 'credential-already-in-use':
        return 'Данные учетной записи уже используются.';
      case 'custom-token-mismatch':
        return 'Невозможно связать кастомный токен с этим пользователем.';
      case 'requires-recent-login':
        return 'Необходим недавний вход для выполнения этой операции.';
      case 'dependent-sdk-initialized-before-auth':
        return 'Зависимый SDK инициализирован до аутентификации.';
      case 'dynamic-link-not-activated':
        return 'Динамические ссылки не активированы.';
      case 'email-change-needs-verification':
        return 'Изменения email требуют подтверждения.';
      case 'email-already-in-use':
        return 'Этот email уже используется другим пользователем.';
      case 'emulator-config-failed':
        return 'Не удалось настроить эмулятор.';
      case 'expired-action-code':
        return 'Код действия устарел.';
      case 'cancelled-popup-request':
        return 'Запрос на всплывающее окно был отменен.';
      case 'internal-error':
        return 'Произошла внутренняя ошибка.';
      case 'invalid-api-key':
        return 'Неверный API-ключ.';
      case 'invalid-app-credential':
        return 'Недействительные учетные данные приложения.';
      case 'invalid-app-id':
        return 'Неверный ID приложения.';
      case 'invalid-user-token':
        return 'Неверный токен пользователя.';
      case 'invalid-auth-event':
        return 'Неверное событие аутентификации.';
      case 'invalid-cert-hash':
        return 'Неверный хеш сертификата.';
      case 'invalid-verification-code':
        return 'Неверный код подтверждения.';
      case 'invalid-continue-uri':
        return 'Неверный URL для продолжения.';
      case 'invalid-cordova-configuration':
        return 'Неверная конфигурация Cordova.';
      case 'invalid-custom-token':
        return 'Неверный кастомный токен.';
      case 'invalid-dynamic-link-domain':
        return 'Неверный домен динамической ссылки.';
      case 'invalid-email':
        return 'Неверный формат email.';
      case 'invalid-emulator-scheme':
        return 'Неверная схема эмулятора.';
      case 'invalid-credential':
        return 'Неверные учетные данные.';
      case 'invalid-message-payload':
        return 'Неверная полезная нагрузка сообщения.';
      case 'invalid-multi-factor-session':
        return 'Неверная сессия для многофакторной аутентификации.';
      case 'invalid-oauth-client-id':
        return 'Неверный идентификатор клиента OAuth.';
      case 'invalid-oauth-provider':
        return 'Неверный поставщик OAuth.';
      case 'invalid-action-code':
        return 'Неверный код действия.';
      case 'unauthorized-domain':
        return 'Недопустимый домен.';
      case 'wrong-password':
        return 'Неверный пароль.';
      case 'invalid-persistence-type':
        return 'Неверный тип постоянства.';
      case 'invalid-phone-number':
        return 'Неверный номер телефона.';
      case 'invalid-provider-id':
        return 'Неверный идентификатор поставщика.';
      case 'invalid-recipient-email':
        return 'Неверный email получателя.';
      case 'invalid-sender':
        return 'Неверный отправитель.';
      case 'invalid-verification-id':
        return 'Неверный идентификатор подтверждения.';
      case 'invalid-tenant-id':
        return 'Неверный идентификатор арендатора.';
      case 'multi-factor-info-not-found':
        return 'Информация для многофакторной аутентификации не найдена.';
      case 'multi-factor-auth-required':
        return 'Требуется многофакторная аутентификация.';
      case 'missing-android-pkg-name':
        return 'Отсутствует имя пакета для Android.';
      case 'missing-app-credential':
        return 'Отсутствуют учетные данные приложения.';
      case 'auth-domain-config-required':
        return 'Требуется конфигурация домена аутентификации.';
      case 'missing-verification-code':
        return 'Отсутствует код подтверждения.';
      case 'missing-continue-uri':
        return 'Отсутствует URL для продолжения.';
      case 'missing-iframe-start':
        return 'Отсутствует стартовый iframe.';
      case 'missing-ios-bundle-id':
        return 'Отсутствует идентификатор пакета iOS.';
      case 'missing-or-invalid-nonce':
        return 'Отсутствует или неверный nonce.';
      case 'missing-multi-factor-info':
        return 'Отсутствует информация для многофакторной аутентификации.';
      case 'missing-multi-factor-session':
        return 'Отсутствует сессия для многофакторной аутентификации.';
      case 'missing-phone-number':
        return 'Отсутствует номер телефона.';
      case 'missing-verification-id':
        return 'Отсутствует идентификатор подтверждения.';
      case 'app-deleted':
        return 'Приложение удалено.';
      case 'account-exists-with-different-credential':
        return 'Аккаунт уже существует с другими учетными данными.';
      case 'network-request-failed':
        return 'Не удалось выполнить сетевой запрос.';
      case 'null-user':
        return 'Пользователь не найден.';
      case 'no-auth-event':
        return 'Не найдено событие аутентификации.';
      case 'no-such-provider':
        return 'Такого поставщика не существует.';
      case 'operation-not-allowed':
        return 'Операция не разрешена.';
      case 'operation-not-supported-in-this-environment':
        return 'Операция не поддерживается в этой среде.';
      case 'popup-blocked':
        return 'Всплывающее окно заблокировано.';
      case 'popup-closed-by-user':
        return 'Всплывающее окно было закрыто пользователем.';
      case 'provider-already-linked':
        return 'Поставщик уже связан с учетной записью.';
      case 'quota-exceeded':
        return 'Превышен лимит квоты.';
      case 'redirect-cancelled-by-user':
        return 'Перенаправление было отменено пользователем.';
      case 'redirect-operation-pending':
        return 'Операция перенаправления еще в процессе.';
      case 'rejected-credential':
        return 'Учетные данные отклонены.';
      case 'second-factor-already-in-use':
        return 'Второй фактор уже используется.';
      case 'maximum-second-factor-count-exceeded':
        return 'Превышено максимальное количество вторичных факторов.';
      case 'tenant-id-mismatch':
        return 'Идентификатор арендатора не совпадает.';
      case 'timeout':
        return 'Время ожидания истекло.';
      case 'user-token-expired':
        return 'Токен пользователя истек.';
      case 'too-many-requests':
        return 'Слишком много запросов.';
      case 'unauthorized-continue-uri':
        return 'Домен URL перенаправления не авторизован.';
      case 'unsupported-first-factor':
        return 'Неподдерживаемый первый фактор.';
      case 'unsupported-persistence-type':
        return 'Неподдерживаемый тип постоянства.';
      case 'unsupported-tenant-operation':
        return 'Операция арендатора не поддерживается.';
      case 'unverified-email':
        return 'Email не подтвержден.';
      case 'user-cancelled':
        return 'Пользователь отменил операцию.';
      case 'user-not-found':
        return 'Пользователь не найден.';
      case 'user-disabled':
        return 'Пользователь отключен.';
      case 'user-mismatch':
        return 'Невозможно связать учетные записи.';
      case 'user-signed-out':
        return 'Пользователь вышел из системы.';
      case 'weak-password':
        return 'Слабый пароль.';
      case 'web-storage-unsupported':
        return 'Web Storage не поддерживается в этом браузере.';
      case 'already-initialized':
        return 'SDK уже инициализирован.';
      case 'recaptcha-not-enabled':
        return 'reCAPTCHA не включен.';
      case 'missing-recaptcha-token':
        return 'Отсутствует токен reCAPTCHA.';
      case 'invalid-recaptcha-token':
        return 'Неверный токен reCAPTCHA.';
      case 'invalid-recaptcha-action':
        return 'Неверное действие reCAPTCHA.';
      case 'missing-client-type':
        return 'Отсутствует тип клиента.';
      case 'missing-client-version':
        return 'Отсутствует версия клиента.';
      default:
        return 'Неизвестная ошибка. Проверьте входные данные.';
    }
  }

}