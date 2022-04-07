import 'dart:async';
import 'dart:convert';

import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toytanks/client.dart';
import 'package:toytanks/screens/mainmenu.dart';
import 'package:web_socket_channel/io.dart';

ToyTanksGame _toyTanksGame = ToyTanksGame();
IOWebSocketChannel? _connection;

class GamePlay extends StatefulWidget {
  const GamePlay({ Key? key }) : super(key: key);

  @override
  State<GamePlay> createState() => _GamePlayState();
}

class _GamePlayState extends State<GamePlay> {
  Map<String, bool> status = {'showGameVariants': true, 'connectionEstablished': false};
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

  void makeHandshake() async {
    String data;
    var prefs = await SharedPreferences.getInstance();
    data = prefs.getString('setup') ?? '';
    _connection?.sink.add(jsonEncode(data));
    
  }

  @override
  Widget build(BuildContext context) {
    //debugPrint('game2 build');
    //debugPrint(status.toString());
    if (status['showGameVariants']!) {
      return GameVariants(callback: () {
        setState(() {
          status['showGameVariants'] = false;
        });
      },);
    }
    if (status['connectionEstablished']!) {
      return GameWidget(game: _toyTanksGame,);
    } else {
      return Material(child: Center(
          child: Text('(${(10 - ticksWaiting / 10).ceil()}) connecting...'),
          ));
    } 
  }
}

class GameVariants extends StatelessWidget {
  final VoidCallback callback;
  const GameVariants({ Key? key, required this.callback }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(onPressed: () => sendVariant('2x2'), child: const Text('2 x 2')),
            ElevatedButton(onPressed: () => sendVariant('3x3'), child: const Text('3 x 3')),
            ElevatedButton(onPressed: () => sendVariant('4x4'), child: const Text('4 x 4')),
          ],
        ),
      ),
    );
  }

  sendVariant(String s) {
    _connection?.sink.add(jsonEncode({'wantGame$s': ''}));
    callback();
  }
}
class ToyTanksGame extends FlameGame {
  
}