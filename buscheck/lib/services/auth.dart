import 'package:firebase_auth/firebase_auth.dart';
//import 'package:buscheck/services/database.dart';
import 'package:buscheck/models/user.dart' as LocalUser;

import 'package:logger/logger.dart';

final Logger logger = Logger();

class AuthService{
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // create user obj based on firebase user
 /* LocalUser.User? _userFromUser(User user) {
    return user != null ? LocalUser.User(uid: user.uid) : null;
  }*/

  LocalUser.User _userFromUser(User? user) {
  if (user != null) {
    return LocalUser.User(uid: user.uid);
  } else {
    return LocalUser.User(uid: ''); // Vagy más kezdeti érték, ha a felhasználó null
  }
}

  // auth change user stream
  Stream<LocalUser.User> get user {
    return _auth.authStateChanges()
      //.map((User user) => _userFromUser(user));
      .map(_userFromUser);
  }

  // sign in anon
  Future signInAnon() async {
     try {
    UserCredential result = await FirebaseAuth.instance.signInAnonymously();
    User? user = result.user;
    if (user != null) {
      return _userFromUser(user);
    } else {
      return null;
    }
  } catch (error) {
    logger.e("Kilépés közbeni hiba: ${error.toString()}");
    return null;
  }
  }
  
  // sign in with email and password
  Future signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(email: email, password: password);
      User? user = result.user;
      return user;
    } catch (error) {
       logger.e("Kilépés közbeni hiba: ${error.toString()}");
      return null;
    } 
  }

  // register with email and password
  Future registerWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
      User? user = result.user;
      // create a new document for the user with the uid
      //await DatabaseService(uid: user.uid).updateUserData('0','new crew member', 100);
      
      return _userFromUser(user);
    } catch (error) {
      logger.e("Kilépés közbeni hiba: ${error.toString()}");
      return null;
    } 
  }

  // sign out
  Future signOut() async {
    try {
      return await _auth.signOut();
    } catch (error) {
      logger.e("Kilépés közbeni hiba: ${error.toString()}");
      return null;
    }
  }
}

