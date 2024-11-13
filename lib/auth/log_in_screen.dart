import 'dart:io';
import 'package:admin_dvij/auth/profile_screen.dart';
import 'package:flutter/material.dart';
import '../constants/system_constants.dart';
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

  void _singIn(String email, String password) async {
    String? uid = await authClass.signInWithEmailAndPassword(email, password);
    if (uid!.isNotEmpty){
      await navigateToProfile();
    }

  }

  Future<void> navigateToProfile()async {

    await Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => const ProfileScreen()
        ),
            (_) => false
    );

  }

  @override
  Widget build(BuildContext context) {

    bool isDesktop = Platform.isWindows || Platform.isMacOS || Platform.isLinux;
    double maxWidth = isDesktop ? 600 : double.infinity; // Ограничение ширины на настольных платформах
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('Экран входа'),
      ),
      body: Center(
        child: Container(
          width: maxWidth,
          padding: const EdgeInsets.all(20),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

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

                TextButton(
                    onPressed: () async {
                      if (emailController.text.isNotEmpty && passwordController.text.isNotEmpty){

                        String? uid = await authClass.signInWithEmailAndPassword(emailController.text, passwordController.text);
                        if (uid != null && uid.isNotEmpty){
                          await navigateToProfile();
                        }
                        //_singIn(emailController.text, passwordController.text);
                      }
                    },
                    child: Text('Войти')
                ),

              ]



          ),
        ),
      ),

    );
  }
}
