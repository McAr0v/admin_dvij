import 'dart:io';
import 'package:admin_dvij/constants/system_constants.dart';
import 'package:admin_dvij/design/loading_screen.dart';
import 'package:admin_dvij/design_elements/button_state_enum.dart';
import 'package:admin_dvij/design_elements/elements_of_design.dart';
import 'package:admin_dvij/design_elements/logo_view.dart';
import 'package:admin_dvij/main_page/main_screen.dart';
import 'package:flutter/material.dart';
import 'auth_class.dart';

class LogInScreen extends StatefulWidget {
  const LogInScreen({Key? key}) : super(key: key);

  @override
  State<LogInScreen> createState() => _LogInScreenState();
}

class _LogInScreenState extends State<LogInScreen> {
  AuthClass authClass = AuthClass();

  bool _isObscured = true;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool loading = false;

  @override
  Widget build(BuildContext context) {

    bool isDesktop = Platform.isWindows || Platform.isMacOS || Platform.isLinux;
    double maxWidth = isDesktop ? 600 : double.infinity; // Ограничение ширины на настольных платформах
    
    return Scaffold(
      body: Center(
        child: Stack(
          children: [
            if (loading) const Center(
              child: LoadingScreen(loadingText: SystemConstants.logIn,),
            ),
            if (!loading) Container(
              width: maxWidth,
              padding: const EdgeInsets.all(20),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [

                    const LogoView(width: 70, height: 70,),

                    Text('Административное приложение', style: Theme.of(context).textTheme.bodySmall,),

                    const SizedBox(height: 50,),

                    TextField(
                      style: Theme.of(context).textTheme.bodyMedium,
                      controller: emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email),
                      ),
                    ),

                    const SizedBox(height: 16.0),

                    // ---- ПОЛЕ ПАРОЛЬ -----

                    TextField(
                      style: Theme.of(context).textTheme.bodyMedium,
                      controller: passwordController,
                      decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.key),
                          labelText: 'Пароль',
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isObscured ? Icons.visibility : Icons.visibility_off,
                            ),
                            onPressed: (){
                              setState(() {
                                _isObscured = !_isObscured;
                              });
                            },
                          )
                      ),
                      // Отобразить / скрыть пароль
                      obscureText: _isObscured,
                    ),

                    const SizedBox(height: 16.0),

                    ElementsOfDesign.customButton(
                        method: () async {
                          _singIn(emailController.text, passwordController.text);
                        },
                        textOnButton: 'Войти',
                        context: context,
                      buttonState: ButtonStateEnum.primary
                    ),
                  ]
              ),
            ),
          ],
        ),
      ),

    );
  }

  void _singIn(String email, String password) async {

    setState(() {
      loading = true;
    });

    String? uid = await authClass.signInWithEmailAndPassword(emailController.text, passwordController.text);

    if (uid != null && uid.isNotEmpty){
      await navigateToProfile(uid);
    }

    setState(() {
      loading = false;
    });

  }

  void _showSnackBar(String message){
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(authClass.getErrorTranslation(message)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> navigateToProfile(String message)async {

    if (emailController.text.isNotEmpty && passwordController.text.isNotEmpty){

      // Если в возвращенном сообщении от Firebase ошибка

      if (!authClass.checkAnswerOnError(message)){

        // Показываем всплывающее меню с уведомлением
        _showSnackBar(message);

      } else {

        // Если в сообщении не ошибка, то переходим на главную страницу
        await Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (context) => const MainPageCustom()
            ),
                (_) => false
        );
      }

    } else {

      if (emailController.text.isEmpty && passwordController.text.isEmpty){
        _showSnackBar(SystemConstants.fillAllFields);
      } else if (emailController.text.isEmpty){
        _showSnackBar(SystemConstants.noEmail);
      } else if (passwordController.text.isEmpty){
        _showSnackBar(SystemConstants.noPassword);
      }
    }
  }
}
