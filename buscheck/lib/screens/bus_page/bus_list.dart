import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BusList extends StatefulWidget {
  const BusList({super.key});

  @override
  State<BusList> createState() => _BusListState();
}

class _BusListState extends State<BusList> {
  late FirebaseAuth _auth;

  @override
  void initState() {
    super.initState();
    _auth = FirebaseAuth.instance;
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: Theme.of(context).iconTheme,
        title: Text(
          'Bus List',
          style: TextStyle(
              fontFamily: 'LilitaOne',
              fontSize: 25,
              color: Theme.of(context).primaryColor),
        ),
        backgroundColor: Colors.cyan[400],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection("Bus").snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasData) {
                  final snap = snapshot.data!.docs;
                  return ListView.builder(
                    shrinkWrap: true,
                    primary: false,
                    itemCount: snap.length,
                    itemBuilder: (context, index) {
                      return Container(
                        height: 70,
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black,
                              offset: Offset(2, 2),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 20),
                                  child: Icon(
                                    Icons.directions_bus,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                                Container(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    " - ${snap[index].id}",
                                    style: TextStyle(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.only(left: 15),
                                  alignment: Alignment.centerLeft,
                                  child: FutureBuilder<double>(
                                    future: getAverageRating(snap[index].id),
                                    builder: (context, ratingSnapshot) {
                                      if (ratingSnapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return CircularProgressIndicator();
                                      } else if (ratingSnapshot.hasError) {
                                        return Text(
                                            'Error: ${ratingSnapshot.error}');
                                      } else {
                                        double averageRating =
                                            ratingSnapshot.data ?? 0.0;
                                        return Text(
                                          "Rating: $averageRating/5.00",
                                          style: TextStyle(
                                            color: Colors.cyan[400],
                                            fontWeight: FontWeight.bold,
                                          ),
                                        );
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              margin: const EdgeInsets.only(right: 20),
                              alignment: Alignment.centerRight,
                              child: RatingBar.builder(
                                initialRating: 0,
                                minRating: 1,
                                direction: Axis.horizontal,
                                allowHalfRating: true,
                                itemCount: 5,
                                itemSize: 26,
                                glowColor: Colors.cyan[400],
                                itemPadding:
                                    const EdgeInsets.symmetric(horizontal: 0.2),
                                itemBuilder: (context, _) => const Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                ),
                                onRatingUpdate: (rating) {
                                  updateRatingInFirestore(
                                      snap[index].id, rating);
                                },
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                } else {
                  return const SizedBox();
                }
              },
            )
          ],
        ),
      ),
    );
  }

  void updateRatingInFirestore(String busId, double rating) {
    User? user = _auth.currentUser;

    if (user != null) {
      String userId = user.uid;

      // Ellenőrizzük, hogy a felhasználó már értékelte-e ezt a buszt
      checkIfUserRatedBus(userId, busId).then((hasRated) {
        if (!hasRated) {
          // Hozzáadjuk az értékelést a "Ratings" kollekcióhoz
          FirebaseFirestore.instance.collection('Ratings').add({
            'busId': busId,
            'userId': userId,
            'rating': rating,
            'timestamp': FieldValue.serverTimestamp(),
          }).then((_) {
            print('Rating added to Ratings collection successfully');

            // Az átlagolt értékelések lekérése
            getAverageRating(busId).then((averageRating) {
              // Frissítjük a Bus kollekciót az átlagolt értékkel
              CollectionReference buses =
                  FirebaseFirestore.instance.collection('Bus');
              buses.doc(busId).update({'Rating': averageRating}).then((value) {
                print('Bus rating updated successfully');
              }).catchError((error) {
                print('Failed to update bus rating: $error');
              });
            });
          }).catchError((error) {
            print('Failed to add rating to Ratings collection: $error');
          });
        } else {
          print('User has already rated this bus.');
        }
      });
    }
  }

  Future<bool> checkIfUserRatedBus(String userId, String busId) async {
    QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await FirebaseFirestore.instance
            .collection('Ratings')
            .where('busId', isEqualTo: busId)
            .where('userId', isEqualTo: userId)
            .get();

    return querySnapshot.docs.isNotEmpty;
  }

  Future<double> getAverageRating(String busId) async {
    QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await FirebaseFirestore.instance
            .collection('Ratings')
            .where('busId', isEqualTo: busId)
            .get();

    List<double> ratings = querySnapshot.docs
        .map((doc) => doc['rating'] as double)
        .toList();

    if (ratings.isNotEmpty) {
      double sum = ratings.reduce((a, b) => a + b);
      double average = sum / ratings.length;

      // Kerekítés egész vagy fél számra
      return (average * 2).roundToDouble() / 2;
    } else {
      return 0.0;
    }
  }
}