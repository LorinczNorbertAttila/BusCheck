import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BusList extends StatefulWidget {
  const BusList({Key? key}) : super(key: key);

  @override
  State<BusList> createState() => _BusListState();
}

class _BusListState extends State<BusList> {
  @override
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
                                  child: Text(
                                    "Rating: ${snap[index]['Rating']}/5.00",
                                    style: TextStyle(
                                      color: Colors.cyan[400],
                                      fontWeight: FontWeight.bold,
                                    ),
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
    CollectionReference buses =
        FirebaseFirestore.instance.collection('Bus');

    buses.doc(busId).update({'Rating': rating}).then((value) {
      print('Bus rating updated successfully');
      showSnackbar(context, 'Rating updated successfully');
    }).catchError((error) {
      print('Failed to update bus rating: $error');
      showSnackbar(context, 'Failed to update rating');
    });
  }

  void showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
