import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

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
    // Initialize Firebase authentication
    _auth = FirebaseAuth.instance;
  }

  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
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
            // StreamBuilder to listen for changes in the "Bus" collection
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection("Bus").snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasData) {

                  if (FirebaseAuth.instance.currentUser != null) {
                     // Extract documents from the snapshot
                    final snap = snapshot.data!.docs;
                    return ListView.builder(
                      shrinkWrap: true,
                      primary: false,
                      itemCount: snap.length,
                      itemBuilder: (context, index) {
                         // Container representing each bus
                        return Container(
                          height: 70,
                          width: double.infinity,
                          margin: EdgeInsets.only(bottom: height * 0.015),
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
                                  // Bus details displayed in a row
                                  Padding(
                                    padding:
                                        EdgeInsets.only(left: width * 0.03),
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
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                   Container(
                                  margin: const EdgeInsets.only(left: 15),
                                  alignment: Alignment.centerLeft,
                                  child: FutureBuilder<double>(
                                    // Display average rating for the bus
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
                                margin: EdgeInsets.only(right: width * 0.03),
                                alignment: Alignment.centerRight,
                                child: RatingBar.builder(
                                  initialRating: 0,
                                  minRating: 1,
                                  direction: Axis.horizontal,
                                  allowHalfRating: true,
                                  itemCount: 5,
                                  itemSize: 26,
                                  glowColor: Colors.cyan[400],
                                  itemPadding: EdgeInsets.symmetric(
                                      horizontal: width * 0.003),
                                  itemBuilder: (context, _) => const Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                  ),
                                  onRatingUpdate: (rating) {
                                  // Update the rating in Firestore when user rates
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
                    final snap = snapshot.data!.docs;
                    return Column(
                      children: [
                         Padding(
                           padding: EdgeInsets.only(bottom: height * 0.02),
                           child: Row(
                                         mainAxisAlignment: MainAxisAlignment.center,
                                         children: [
                                           const Text(
                                             'If you want to rate the buses, ',
                                             style: TextStyle(fontFamily: 'LilitaOne', fontSize: 15),
                                           ),
                                           InkWell(
                                             onTap: () {
                                               Navigator.pushNamed(context, '/signin');
                                             },
                                             child: const Text(
                                               'SIGN IN',
                                               style: TextStyle(fontFamily: 'LilitaOne', fontSize: 15),
                                             ),
                                           ),
                                         ],
                                       ),
                         ),
            
                        ListView.builder(
                      shrinkWrap: true,
                      primary: false,
                      itemCount: snap.length,
                      itemBuilder: (context, index) {
                        return Container(
                          height: 70,
                          width: double.infinity,
                          margin: EdgeInsets.only(bottom: height * 0.015),
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
                                    padding:
                                        EdgeInsets.only(left: width * 0.03),
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
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Container(
                                  margin: const EdgeInsets.only(left: 15),
                                  alignment: Alignment.centerLeft,
                                  child: FutureBuilder<double>(
                                    // Display average rating for the bus
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
                            ],
                          ),
                        );
                      },
                    
                    ),
                    ],
                    );
                  }
                } else {
                  // Return an empty container if no data is available
                  return const SizedBox();
                }
              },
            )
          ],
        ),
      ),
    );
  }

  // Update Firestore with the user's rating for a specific bus
  void updateRatingInFirestore(String busId, double rating) {
    User? user = _auth.currentUser;

    if (user != null) {
      String userId = user.uid;

      // Check if the user has already rated this bus
      checkIfUserRatedBus(userId, busId).then((hasRated) {
        if (!hasRated) {
          // Add the rating to the "Ratings" collection
          FirebaseFirestore.instance.collection('Ratings').add({
            'busId': busId,
            'userId': userId,
            'rating': rating,
            'timestamp': FieldValue.serverTimestamp(),
          }).then((_) {
            print('Rating added to Ratings collection successfully');

            // Retrieve and update average ratings
            getAverageRating(busId).then((averageRating) {
              // Update the Bus collection with the average rating
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

  // Check if the user has already rated a specific bus
  Future<bool> checkIfUserRatedBus(String userId, String busId) async {
    QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await FirebaseFirestore.instance
            .collection('Ratings')
            .where('busId', isEqualTo: busId)
            .where('userId', isEqualTo: userId)
            .get();

    return querySnapshot.docs.isNotEmpty;
  }

  // Retrieve the average rating for a specific bus
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

      // Round to the nearest half or whole number
      return (average * 2).roundToDouble() / 2;
    } else {
      return 0.0;
    }
  }
}
