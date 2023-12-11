import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SearchBus extends StatefulWidget {
  const SearchBus({Key? key}) : super(key: key);

  @override
  _ValamiState createState() => _ValamiState();
}

class _ValamiState extends State<SearchBus> {
  String searchQuery = '';
  late TextEditingController searchController;
  String selectedSearchType = 'Bus'; // Default value

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
    return Scaffold(
      appBar: AppBar(
        title: Text('Firestore Data'),
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
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          var busLines = snapshot.data?.docs;

          return ListView.builder(
            itemCount: busLines?.length,
            itemBuilder: (context, index) {
              var busIdReference = busLines?[index]['Bus_ID'] as DocumentReference?;
              var arrivalTimes = busLines?[index]['Arrival time'] as List<dynamic>? ?? [];
              var busStopsReferences = busLines?[index]['Bus stops_ID'] as List<dynamic>? ?? [];

              return FutureBuilder(
                future: busIdReference?.get(),
                builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> busSnapshot) {
                  if (busSnapshot.connectionState == ConnectionState.waiting) {
                    return SizedBox.shrink(); // Ha még mindig tölt, ne jelenjen meg semmi
                  }

                  if (busSnapshot.hasError || busSnapshot.data == null) {
                    return SizedBox.shrink(); // Ha hiba van, vagy nincs adat, ne jelenjen meg semmi
                  }

                  var busId = busSnapshot.data?.id;

                  // Feltétel vizsgálata, és a megfelelő widget visszaadása
                  return _buildListTile(busId, busStopsReferences, arrivalTimes);
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildListTile(String? busId, List<dynamic> busStopsReferences, List<dynamic> arrivalTimes) {
    return FutureBuilder(
      future: _hasQuery(busId, busStopsReferences, searchQuery),
      builder: (BuildContext context, AsyncSnapshot<bool> hasQuerySnapshot) {
        if (hasQuerySnapshot.connectionState == ConnectionState.waiting) {
          return SizedBox.shrink(); // Ha még mindig tölt, ne jelenjen meg semmi
        }

        if (hasQuerySnapshot.hasError) {
          return SizedBox.shrink(); // Ha hiba van, ne jelenjen meg semmi
        }

        var hasQuery = hasQuerySnapshot.data ?? false;

        if (hasQuery) {
          // Ha van találat, akkor megjelenítjük a csempét
          return ListTile(
            title: Text('Bus Number: $busId'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Bus stops_ID
                FutureBuilder(
                  future: _getBusStopsWithTime(busStopsReferences, arrivalTimes),
                  builder: (BuildContext context, AsyncSnapshot<List<String>> stopsSnapshot) {
                    if (stopsSnapshot.connectionState == ConnectionState.waiting) {
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
          // Ha nincs találat, üres widgetet adunk vissza
          return SizedBox.shrink();
        }
      },
    );
  }

  Future<void> _showSearchDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Search Bus by Name or Stop'),
          content: Column(
            children: [
              DropdownButton<String>(
                value: selectedSearchType,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedSearchType = newValue!;
                  });
                },
                items: <String>['Bus', 'Stop'].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              SizedBox(height: 16),
              TextField(
                controller: searchController,
                onChanged: (value) {
                  setState(() {
                    searchQuery = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Enter ${selectedSearchType == 'Bus' ? 'Bus Name' : 'Stop Name'}',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  searchQuery = '';
                  searchController.clear();
                });
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  Future<List<String>> _getBusStopsWithTime(List<dynamic> busStopsReferences, List<dynamic> arrivalTimes) async {
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

  Future<bool> _hasQuery(String? busId, List<dynamic> busStopsReferences, String query) async {
    if (busId != null && busId.toLowerCase().contains(query.toLowerCase())) {
      return true;
    }

    for (var reference in busStopsReferences) {
      if (reference is DocumentReference) {
        var stopSnapshot = await reference.get();
        if (stopSnapshot.exists) {
          var name = stopSnapshot['Name'] as String?;
          if (name != null && name.toLowerCase().contains(query.toLowerCase())) {
            return true;
          }
        }
      }
    }

    return false;
  }
}