import 'dart:io';

import 'package:bandnames/models/band.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Band> bands = [
    Band(id: '1', name: 'Acid King', votes: 5),
    Band(id: '2', name: 'Weedpecker', votes: 5),
    Band(id: '3', name: 'Bongzilla', votes: 5),
    Band(id: '4', name: 'Slo Burn', votes: 5)
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Band names',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 1.0,
      ),
      body: ListView.builder(
          itemCount: bands.length,
          itemBuilder: (context, i) {
            return _bandTile(bands[i]);
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: addNewBand,
        child: Icon(Icons.add),
        elevation: 1.0,
      ),
    );
  }

  Widget _bandTile(Band band) => Dismissible(
        direction: DismissDirection.startToEnd,
        onDismissed: (direction){},
        background: Container(
          padding: EdgeInsets.only(left: 8.0),
          color: Colors.red,
          child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Borrar',
                style: TextStyle(color: Colors.white),
              )),
        ),
        key: Key(band.id),
        child: ListTile(
          leading: CircleAvatar(
            child: Text(band.name.substring(0, 2)),
          ),
          title: Text(band.name),
          trailing: Text(
            '${band.votes}',
            style: TextStyle(fontSize: 20.0),
          ),
          onTap: () {
            print(band.name);
          },
        ),
      );

  addNewBand() {
    final textController = new TextEditingController();
    if (Platform.isAndroid) {
      return showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: Text('New Band Name: '),
                content: TextField(
                  controller: textController,
                ),
                actions: [
                  MaterialButton(
                    child: Text('add'),
                    elevation: 5.0,
                    textColor: Colors.blue,
                    onPressed: () => addBandToList(textController.text),
                  )
                ],
              ));
    }

    showCupertinoDialog(
        context: context,
        builder: (_) => CupertinoAlertDialog(
              title: Text('New band name'),
              content: CupertinoTextField(controller: textController),
              actions: [
                CupertinoDialogAction(
                  isDefaultAction: true,
                  child: Text('Add'),
                  onPressed: () => addBandToList(textController.text),
                ),
                CupertinoDialogAction(
                  isDestructiveAction: true,
                  child: Text('Dismiss'),
                  onPressed: () => Navigator.pop(context),
                )
              ],
            ));
  }

  void addBandToList(String name) {
    if (name.length > 1) {
      final now = DateTime.now().toString();
      bands.add(Band(id: now, name: name, votes: 0));
      setState(() {});
    }
    Navigator.pop(context);
  }
}
