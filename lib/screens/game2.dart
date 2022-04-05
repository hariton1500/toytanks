import 'dart:async';

import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:toytanks/client.dart';
import 'package:toytanks/main.dart';
import 'package:toytanks/screens/mainmenu.dart';
import 'package:web_socket_channel/io.dart';

ToyTanksGame _toyTanksGame = ToyTanksGame();

class GamePlay extends StatefulWidget {
  const GamePlay({ Key? key }) : super(key: key);

  @override
  State<GamePlay> createState() => _GamePlayState();
}

class _GamePlayState extends State<GamePlay> {
  
  late IOWebSocketChannel _connection;
  dynamic res;
  bool connectionEstablished = false;
  int ticksWaiting = 0;

  @override
  void initState() {
    super.initState();
    res = startConnection();
    Timer.periodic(const Duration(milliseconds: 100), (timer) => checkConnection(timer));
  }

  void checkConnection(Timer timer) {
    //debugPrint((timer.tick % 10).toString());
    //debugPrint(connectionEstablished.toString());
    if (timer.tick >= 100) {
      timer.cancel();
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const MainMenu()));
    }
    if (res is IOWebSocketChannel) {
      _connection = res;
    }
    if (_connection.protocol != null) {
      setState(() {
        connectionEstablished = true;
        timer.cancel();
      });
    }
    setState(() {
      ticksWaiting = timer.tick;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (connectionEstablished) {
      return GameWidget(game: _toyTanksGame,);
    } else {
      return Material(child: Center(
          child: Text('(${(ticksWaiting / 10).ceil()}) connecting...'),
          ));
    }
  }
}