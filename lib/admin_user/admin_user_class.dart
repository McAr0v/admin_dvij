import 'package:admin_dvij/auth/auth_class.dart';
import 'package:admin_dvij/constants/database_constants.dart';
import 'package:admin_dvij/constants/system_constants.dart';
import 'package:firebase_database/firebase_database.dart';

class AdminUserClass {
  String uid;
  String name;
  String lastName;
  String phone;
  String email;
  DateTime birthDate;
  String avatar;
  DateTime registrationDate;

  AdminUserClass({
    required this.uid,
    required this.name,
    required this.lastName,
    required this.phone,
    required this.email,
    required this.birthDate,
    required this.avatar,
    required this.registrationDate
  });

  AdminUserClass? _currentUser;

  factory AdminUserClass.empty() {
    return AdminUserClass(
        uid: '',
        name: '',
        lastName: '',
        phone: '',
        email: '',
        birthDate: DateTime(2100),
        avatar: SystemConstants.defaultAvatar,
        registrationDate: DateTime(2100)
    );
  }

  factory AdminUserClass.fromSnapshot(DataSnapshot snapshot){

    DateTime birthDate = DateTime.parse(snapshot.child(DatabaseConstants.birthDate).value.toString());
    DateTime regDate = DateTime.parse(snapshot.child(DatabaseConstants.registrationDate).value.toString());

    return AdminUserClass(
        uid: snapshot.child(DatabaseConstants.uid).value.toString(),
        name: snapshot.child(DatabaseConstants.name).value.toString(),
        lastName: snapshot.child(DatabaseConstants.lastName).value.toString(),
        phone: snapshot.child(DatabaseConstants.phone).value.toString(),
        email: snapshot.child(DatabaseConstants.email).value.toString(),
        birthDate: birthDate,
        avatar: snapshot.child(DatabaseConstants.avatar).value.toString(),
        registrationDate: regDate
    );
  }

  Future<String> signOut() async {
    AuthClass authClass = AuthClass();
    return await authClass.signOut();
  }

  AdminUserClass getCurrentUser(){
    return _currentUser ?? AdminUserClass.empty();
  }

  void setCurrentUser(AdminUserClass user){
    _currentUser = user;
  }

  
}