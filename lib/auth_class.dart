import 'package:admin_dvij/constants/system_constants.dart';
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

  Future<String?> signOut() async{
    try {
      await FirebaseAuth.instance.signOut();

      return SystemConstants.successConst;

    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> signInWithEmailAndPassword(String emailAddress, String password) async {
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
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
}