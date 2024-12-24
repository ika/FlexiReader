import 'dart:async';
import 'package:flexireader/db/database.dart';
import 'package:flexireader/models/fmodel.dart';
import 'package:flexireader/models/jmodel.dart';
import 'package:flexireader/views/edit.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// feeds.dart

DBProvider dbProvider = DBProvider();

class FeedsPage extends StatefulWidget {
  const FeedsPage({super.key, required this.title});

  final String title;

  @override
  FeedsPageState createState() => FeedsPageState();
}

class FeedsPageState extends State<FeedsPage> {
  final _fapLocation = FloatingActionButtonLocation.endDocked;

  // @override
  // void initState() {
  //   super.initState();
  // }

  void _encodeFeedListItemData(FModel fmodel) async {
    final String encodedData = JModel.encode([
      JModel(title: fmodel.title, link: fmodel.link, feedid: fmodel.feedid),
    ]);

    debugPrint(encodedData);

    // save encoded data
    await SharedPreferences.getInstance().then((prefs) {
      prefs.setString("jmodelEncodedData", encodedData);
    });
    // update feed item time stamp
    await _updateFeedListItemTime(fmodel).then(
      (value) {
        // return to News
        if (mounted) {
          Navigator.pop(context, encodedData);
        }
      },
    );
  }

  // update time stamp
  Future<Null> _updateFeedListItemTime(FModel fmodel) async {
    fmodel.time = DateTime.now().microsecondsSinceEpoch;
    dbProvider.updateFeedItem(fmodel);
  }

  String shortenTitle(String n) {
    int len = 40;
    String title = (n.length > len) ? '${n.substring(0, len)}...' : n;
    return title;
  }

  FutureOr onReturnFromEditPage(dynamic value) {
    setState(() {});
  }

  _navigateToEditPage(FModel fModel) async {
    Route route =
        CupertinoPageRoute(builder: (context) => EditPage(fModel: fModel));
    Navigator.push(context, route).then(onReturnFromEditPage);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true, // this is the default
        backgroundColor: Colors.blue,
        title: Text(
          widget.title,
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: FutureBuilder<List<FModel>>(
              future: dbProvider.getAllFeedItems(),
              builder:
                  (BuildContext context, AsyncSnapshot<List<FModel>> snapshot) {
                // Make sure data exists and is actually loaded
                if (snapshot.hasData) {
                  // If there are no notes (data), display this message.
                  if (snapshot.data!.isEmpty) {
                    return Center(
                      child: Text('No items found'),
                    );
                  }

                  List<FModel> data = snapshot.data!;

                  return ListView.builder(
                    padding: const EdgeInsets.only(bottom: 88),
                    itemCount: snapshot.data!.length,
                    itemBuilder: (BuildContext context, int index) {
                      FModel fmodel = data[index];

                      return Column(
                        children: <Widget>[
                          ListTile(
                            title: Text(shortenTitle(fmodel.title!)),
                            onTap: () {
                              _encodeFeedListItemData(fmodel);
                            },
                            onLongPress: () {
                              _navigateToEditPage(fmodel);
                            },
                            leading:
                                Icon(Icons.chevron_right, color: Colors.blue),
                          ),
                          Divider(
                            height: 2.0,
                            indent: 15.0,
                            endIndent: 20.0,
                          ),
                        ],
                      );
                    },
                  );
                }
                return Center(
                  child: CircularProgressIndicator(),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: () {
          _navigateToEditPage(FModel(id: null, title: '', link: ''));
        },
        tooltip: 'Add feed',
        child: Icon(Icons.add, color: Colors.white,),
      ),
      floatingActionButtonLocation: _fapLocation,
      bottomNavigationBar: _BottomAppBar(
        fabLocation: _fapLocation,
        shape: CircularNotchedRectangle(),
      ),
    );
  }
}

class _BottomAppBar extends StatelessWidget {
  const _BottomAppBar({
    required this.fabLocation,
    required this.shape,
  });

  final FloatingActionButtonLocation fabLocation;
  final NotchedShape shape;

  static final centerLocations = <FloatingActionButtonLocation>[
    FloatingActionButtonLocation.centerDocked,
    FloatingActionButtonLocation.centerFloat,
  ];

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: shape,
      child: IconTheme(
        data: IconThemeData(color: Colors.blue),
        child: Row(
          children: [
            IconButton(
              tooltip: '',
              icon: const Icon(Icons.menu),
              onPressed: () {
                throw ('Menu button pressed');
              },
            ),
            if (centerLocations.contains(fabLocation)) const Spacer(),
            IconButton(
              tooltip: 'Tooltip',
              icon: const Icon(Icons.search),
              onPressed: () {
                throw ('Search button pressed');
              },
            ),
            IconButton(
              tooltip: 'tooltip',
              icon: const Icon(Icons.favorite),
              onPressed: () {
                throw ('Favorite button pressed');
              },
            ),
          ],
        ),
      ),
    );
  }
}
