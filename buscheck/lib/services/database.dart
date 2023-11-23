import 'package:buscheck/models/bus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final CollectionReference busCollection =
      FirebaseFirestore.instance.collection('Bus');

  //bus list
  List<Bus> _busListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      List<String> stops = [
        doc['Place of Departure'] ?? '',
        doc['Terminal Point'] ?? ''
      ];
      return Bus(id: doc.id, rating: doc['Rating'] ?? 0, stops: stops);
    }).toList();
  }

  //get bus stream
  Stream<List<Bus>> get buses {
    return busCollection.snapshots().map(_busListFromSnapshot);
  }
}
