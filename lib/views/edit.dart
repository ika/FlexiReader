import 'package:flexireader/db/database.dart';
import 'package:flexireader/models/fmodel.dart';
import 'package:flutter/material.dart';


DBProvider dbProvider = DBProvider();

String? feedFunction;

int? id;
String? title;
String? link;

class EditPage extends StatefulWidget {
  const EditPage({super.key, required this.fModel});

  final FModel fModel;

  @override
  EditPageState createState() => EditPageState();
}

class EditPageState extends State<EditPage> {
  final TextEditingController _controllerTitle = TextEditingController();
  final TextEditingController _controllerLink = TextEditingController();
  bool isSaved = true;

  @override
  void initState() {
    super.initState();
    id = widget.fModel.id;
    _controllerTitle.text = widget.fModel.title as String;
    _controllerLink.text = widget.fModel.link as String;

    if (id == null) {
      feedFunction = 'Add feed';
    } else {
      feedFunction = 'Edit feed';
    }

    // Start listening to changes.
    _controllerTitle.addListener(handleOnChange);
    _controllerLink.addListener(handleOnChange);
  }

  @override
  void dispose() {
    _controllerTitle.dispose();
    _controllerLink.dispose();
    super.dispose();
  }

  handleOnChange() {
    if (id == null) {
      // no id, save
      _saveEdit();
    } else {
      // with id, update
      _updateEdit();
    }
  }

  _saveEdit() async {
    int time = DateTime.now().microsecondsSinceEpoch;
    await dbProvider
        .insertFeedItem(FModel(
            title: _controllerTitle.text,
            link: _controllerLink.text,
            feedid: 0,
            time: time))
        .then((res) {
      id = res; // populate 'id' so that it is not saved more than once
    });
  }

  _updateEdit() async {
    int time = DateTime.now().microsecondsSinceEpoch;
    await dbProvider.updateFeedItem(FModel(
        id: id,
        title: _controllerTitle.text,
        link: _controllerLink.text,
        feedid: 0,
        time: time));
  }

  void _deleteEdit() async {
    await dbProvider.deleteFeedItem(id!).then(
      (value) {
        int count = 0;
        if (mounted) {
          Navigator.popUntil(
            context,
            (route) {
              return count++ == 2;
            },
          );
        }
      },
    );
  }

  _deleteDialogWrapper() {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Delete?',
          style: TextStyle(color: Colors.red),
        ),
        content: Text(_controllerTitle.text),
        actions: <Widget>[
          TextButton(
            child: Text('NO'),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          TextButton(
            onPressed: _deleteEdit,
            child: Text('YES'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text(feedFunction!, style: TextStyle(color: Colors.white),),
        actions: [
          IconButton(
            icon: Icon(Icons.delete, color: Colors.white),
            onPressed: _deleteDialogWrapper,
          )
        ],
      ),
      body: Form(
        child: Padding(
          padding: EdgeInsets.only(top: 15.0, left: 15.0, right: 15.0),
          child: ListView(
            children: [
              Padding(
                padding: EdgeInsets.only(top: 15.0),
                child: TextFormField(
                  controller: _controllerTitle,
                  maxLength: 256,
                  //maxLines: null, // auto line break
                  decoration: InputDecoration(
                    labelText: 'Title',
                    labelStyle: Theme.of(context).textTheme.titleMedium,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
                child: TextFormField(
                  controller: _controllerLink,
                  maxLength: 256,
                  //maxLines: null, // auto line break
                  decoration: InputDecoration(
                    labelText: 'Link',
                    labelStyle: Theme.of(context).textTheme.titleMedium,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
