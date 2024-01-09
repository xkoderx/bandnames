import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

enum ServerStatus {
  Online,
  Offline,
  Connecting
}
class  SocketProvider with ChangeNotifier {
  late ServerStatus _serverStatus = ServerStatus.Connecting;
  late IO.Socket _socket;

  ServerStatus get serverStatus => _serverStatus;
  IO.Socket get socket => _socket;

  SocketProvider(){
    _initConfig();
    _socket;
  }

  void _initConfig() {
    // Dart client
    _socket = IO.io('http://192.168.1.191:3000',{
      'transports':['websocket'],
      'autoConnect':true
    });
    _socket.onConnect((_) {
      _serverStatus = ServerStatus.Online;
      notifyListeners();
    });
    _socket.onDisconnect((_) {
      _serverStatus = ServerStatus.Offline;
       notifyListeners();
    });
    socket.on('nuevo-mensaje', (payload) => print('nuevo-mensaje: $payload'));
  }
}
