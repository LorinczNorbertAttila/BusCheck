import 'package:buscheck/models/brew.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:buscheck/models/user.dart';


class DatabaseService {

  final String uid;
  DatabaseService({required this.uid });

  // collection reference
  final CollectionReference brewCollection = FirebaseFirestore.instance.collection('brews');

  Future<void> updateUserData(String name, String email, String password) async {
    return await brewCollection.doc(uid).set({
      'name': name,
      'email':email,
      'password': password,
    });
  }

  // brew list from snapshot
  List<Brew> _brewListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc){
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>; 
      return Brew(
      name: data['name'] ?? '', 
      email: data['strength'] ?? '',
      password: data['sugars'] ?? ''
      );
    }).toList();
  }

  // user data from snapshots
  UserData _userDataFromSnapshot(DocumentSnapshot snapshot) {
    Map<String, dynamic>? data = snapshot.data() as Map<String, dynamic>?;
  if (data == null) {
    return UserData(uid: uid, name: '', email: '', password: '');
  }

  return UserData(
    uid: uid,
    name: data['name'] ?? '',
    email: data['email'] ?? '',
    password: data['password'] ?? '',
  );
  }

  // get brews stream
  Stream<List<Brew>> get brews {
    return brewCollection.snapshots()
    .map( _brewListFromSnapshot);
  }

  // get user doc stream
  Stream<UserData> get userData {
    return brewCollection.doc(uid).snapshots()
      .map(_userDataFromSnapshot);
  }

}