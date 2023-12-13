import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Widget class for the main search functionality
class SearchBus extends StatefulWidget {
  const SearchBus({Key? key}) : super(key: key);

  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<SearchBus> {
  String searchQuery = '';
  late TextEditingController searchController;
  String selectedSearchType = 'Bus'; // Default value
  List<dynamic>? busLines;

  @override
  void initState() {
    super.initState();
    searchController = TextEditingController();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Scaffold widget for the main UI structure
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
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () => _showSearchDialog(context),
          ),
        ],
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('Bus lines').snapshots(),
        builder: (context, snapshot) {
          // Check connection state and show appropriate UI
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          var busLines = snapshot.data?.docs;

          // Display a list of bus lines based on Firestore data
          return ListView.builder(
            itemCount: busLines?.length,
            itemBuilder: (context, index) {
              var busIdReference =
                  busLines?[index]['Bus_ID'] as DocumentReference?;
              var arrivalTimes =
                  busLines?[index]['Arrival time'] as List<dynamic>? ?? [];
              var busStopsReferences =
                  busLines?[index]['Bus stops_ID'] as List<dynamic>? ?? [];

              // Display bus information asynchronously using FutureBuilder
              return FutureBuilder(
                future: busIdReference?.get(),
                builder: (BuildContext context,
                    AsyncSnapshot<DocumentSnapshot> busSnapshot) {
                  if (busSnapshot.connectionState == ConnectionState.waiting) {
                    return SizedBox
                        .shrink(); // Don't show anything while still loading
                  }

                  if (busSnapshot.hasError || busSnapshot.data == null) {
                    return SizedBox
                        .shrink(); // Don't show anything if there's an error or no data
                  }

                  var busId = busSnapshot.data?.id;

                  // Check condition and return the appropriate widget
                  return _buildListTile(
                      busId, busStopsReferences, arrivalTimes);
                },
              );
            },
          );
        },
      ),
    );
  }

  // Build a ListTile widget based on search results

  Widget _buildListTile(String? busId, List<dynamic> busStopsReferences,
      List<dynamic> arrivalTimes) {
    return FutureBuilder(
      future: _hasQuery(busId, busStopsReferences, searchQuery),
      builder: (BuildContext context, AsyncSnapshot<bool> hasQuerySnapshot) {
        if (hasQuerySnapshot.connectionState == ConnectionState.waiting) {
          return SizedBox.shrink(); // Don't show anything while still loading
        }

        if (hasQuerySnapshot.hasError) {
          return SizedBox.shrink(); // Don't show anything if there's an error
        }

        var hasQuery = hasQuerySnapshot.data ?? false;

        // Display ListTile if there's a match, otherwise return an empty widget
        if (hasQuery) {
          return ListTile(
            title: Text('Bus Number: $busId'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Display bus stops asynchronously using FutureBuilder
                FutureBuilder(
                  future:
                      _getBusStopsWithTime(busStopsReferences, arrivalTimes),
                  builder: (BuildContext context,
                      AsyncSnapshot<List<String>> stopsSnapshot) {
                    if (stopsSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    }

                    if (stopsSnapshot.hasError) {
                      return Text('Error: ${stopsSnapshot.error}');
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Bus Stops:'),
                        for (var stopInfo in stopsSnapshot.data!)
                          Text(stopInfo),
                      ],
                    );
                  },
                ),
              ],
            ),
          );
        } else {
          return SizedBox
              .shrink(); // Return an empty widget if there's no match
        }
      },
    );
  }

  // Show a search dialog to input search queries
  Future<void> _showSearchDialog(BuildContext context) async {
    searchController
        .clear(); // Always clear the TextField value before a new search

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Search Bus by Name or Stop'),
          content: Column(
            children: [
              SizedBox(height: 16),
              TextField(
                controller: searchController,
                onChanged: (value) {
                  setState(() {
                    searchQuery = value;
                  });
                },
                decoration: InputDecoration(
                  hintText:
                      'Enter ${selectedSearchType == 'Bus' ? 'Bus Name' : 'Stop Name'}',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                // Close the dialog
                Navigator.of(context).pop();
                // Perform the search
                await _performSearch();
              },
              child: Text('OK'),
            ),
            TextButton(
              onPressed: () {
                // Clear the search query, then close the dialog
                _clearSearch();
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  // Clear the search query
  void _clearSearch() {
    setState(() {
      searchQuery = '';
    });
  }

  // Retrieve bus stops with arrival times
  Future<List<String>> _getBusStopsWithTime(
      List<dynamic> busStopsReferences, List<dynamic> arrivalTimes) async {
    List<String> stopsWithTime = [];

    for (var i = 0; i < busStopsReferences.length; i++) {
      var reference = busStopsReferences[i];
      var time = i < arrivalTimes.length ? arrivalTimes[i] : null;

      if (reference is DocumentReference && time != null) {
        var stopSnapshot = await reference.get();
        if (stopSnapshot.exists) {
          var stopName = stopSnapshot['Name'] as String?;
          if (stopName != null) {
            stopsWithTime.add('$stopName - $time');
          }
        }
      }
    }

    return stopsWithTime;
  }

  // Check if there's a match for the search query
  Future<bool> _hasQuery(
      String? busId, List<dynamic> busStopsReferences, String query) async {
    bool hasBusIdMatch =
        busId != null && busId.toLowerCase().contains(query.toLowerCase());

    if (hasBusIdMatch) {
      return true;
    }

    for (var reference in busStopsReferences) {
      if (reference is DocumentReference) {
        var stopSnapshot = await reference.get();
        if (stopSnapshot.exists) {
          var name = stopSnapshot['Name'] as String?;
          if (name != null &&
              name.toLowerCase().contains(query.toLowerCase())) {
            return true;
          }
        }
      }
    }

    // No result
    return false;
  }

//test search
  Future<void> _performSearch() async {
    var matchingResults = <dynamic>[];

    for (var busLine in busLines ?? []) {
      var hasQuery = await _hasQuery(
        busLine['Bus_ID'],
        busLine['Bus stops_ID'],
        searchQuery,
      );

      if (hasQuery) {
        matchingResults.add(busLine);
      }
    }

    // Only execute setState if we have actually found results
    if (matchingResults.isNotEmpty) {
      setState(() {});
    } else {
      // If no match is found, display the message
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No matching results found.'),
        ),
      );
    }
  }
}
