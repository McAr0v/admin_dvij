import 'package:firebase_auth/firebase_auth.dart';

class AuthClass{

  Future<String?> createUserWithEmailAndPassword(String email, String password) async {
    try{
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);

      User? user = credential.user;

      return user?.uid;
    } on FirebaseAuthException catch (e) {
      return e.code;
    }
  }



}