import 'dart:async';

import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:toytanks/client.dart';
import 'package:toytanks/main.dart';
import 'package:toytanks/screens/mainmenu.dart';
import 'package:toytanks/screens/setup.dart';
import 'package:web_socket_channel/io.dart';

ToyTanksGame _toyTanksGame = ToyTanksGame();

class GamePlay extends StatefulWidget {
  const GamePlay({ Key? key }) : super(key: key);

  @override
  State<GamePlay> createState() => _GamePlayState();
}

class _GamePlayState extends State<GamePlay> {
  Map<String, bool> status = {'setupComplited': false, 'connectionEstablished': false};
  IOWebSocketChannel? _connection;
  dynamic res;
  //bool connectionEstablished = false;
  int ticksWaiting = 0;

  @override
  void initState() {
    super.initState();
    res = startConnection();
    Timer.periodic(const Duration(milliseconds: 100), (timer) => checkConnection(timer));
  }

  void checkConnection(Timer timer) {
    if (timer.tick >= 100) {
      timer.cancel();
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const MainMenu()));
    }
    if (res is IOWebSocketChannel && _connection is! IOWebSocketChannel) {
      _connection = res;
    }
    if (_connection?.innerWebSocket != null) {
      setState(() {
        status['connectionEstablished'] = true;
        timer.cancel();
        makeHandshake();
      });
    }
    setState(() {
      ticksWaiting = timer.tick;
    });
  }

  void makeHandshake() {
    
  }

  @override
  Widget build(BuildContext context) {
    if (!status['setupComplited']!) {
      return const SetupPage();
    }
    if (status['connectionEstablished']!) {
      return GameWidget(game: _toyTanksGame,);
    } else {
      return Material(child: Center(
          child: Text('(${(ticksWaiting / 10).ceil()}) connecting...'),
          ));
    } 
  }
}