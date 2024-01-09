import 'dart:io';
import 'package:bandnames/models/band.dart';
import 'package:bandnames/providers/socket.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:provider/provider.dart';
import 'package:socket_io_client/socket_io_client.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Band> bands = [
    // Band(id: '1', name: 'Acid King', votes: 5),
    // Band(id: '2', name: 'Weedpecker', votes: 5),
    // Band(id: '3', name: 'Bongzilla', votes: 5),
    // Band(id: '4', name: 'Slo Burn', votes: 5)
  ];

  @override
  void initState() {
    final socketService = Provider.of<SocketProvider>(context, listen: false);
    socketService.socket.on('bandas-activas', _handleActiveBands);
    super.initState();
  }

  _handleActiveBands(dynamic payload) {
    bands = (payload as List).map((band) => Band.fromMap(band)).toList();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final serverStatus = Provider.of<SocketProvider>(context);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Band names',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 1.0,
        actions: [
          serverStatus.socket.connected
              ? Icon(
                  Icons.check_circle,
                  color: Colors.green[500],
                )
              : Icon(
                  Icons.offline_bolt,
                  color: Colors.red,
                ),
        ],
      ),
      body: Column(
        children: [
          _showGraph(),
          Expanded(
            child: ListView.builder(
                itemCount: bands.length,
                itemBuilder: (context, i) {
                  return _bandTile(bands[i]);
                }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addNewBand,
        child: Icon(Icons.add),
        elevation: 1.0,
      ),
    );
  }

  Widget _bandTile(Band band) => Dismissible(
        key: Key(band.id),
        direction: DismissDirection.startToEnd,
        onDismissed: (_) {
          final socketService =
              Provider.of<SocketProvider>(context, listen: false).socket;
          socketService.emit('borrar-banda', {'id': band.id});
        },
        background: Container(
          padding: EdgeInsets.only(left: 8.0),
          color: Colors.red,
          child: const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Borrar',
                style: TextStyle(color: Colors.white),
              )),
        ),
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
            final socketService =
                Provider.of<SocketProvider>(context, listen: false).socket;
            socketService.emit('voto-banda', {'id': band.id});
          },
        ),
      );

  addNewBand() {
    final textController = TextEditingController();
    if (Platform.isAndroid) {
      return showDialog(
        context: context,
        builder: (_) => AlertDialog(
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
        ),
      );
    }

    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: Text('New band name'),
        content: CupertinoTextField(controller: textController),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            child: Text('Agregar'),
            onPressed: () => addBandToList(textController.text),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: Text('Dismiss'),
            onPressed: () => Navigator.pop(context),
          )
        ],
      ),
    );
  }

  void addBandToList(String name) {
    if (name.length > 1) {
      final socketService = Provider.of<SocketProvider>(context, listen: false);
      socketService.socket.emit('agregar-banda', {'name': name});
    }
    Navigator.pop(context);
  }

  Widget _showGraph() {
    Map<String, double> data = {};
    //data.putIfAbsent('Flutter', () => 5);
    for (var band in bands) {
      data.putIfAbsent(band.name, () => band.votes!.toDouble());
    }

    return SizedBox(
      width: double.infinity,
      height: 200,
      child: PieChart(
        dataMap: data,
        chartValuesOptions: const ChartValuesOptions(
            showChartValuesInPercentage: true,
            decimalPlaces: 0),
      ),
    );
  }
}
