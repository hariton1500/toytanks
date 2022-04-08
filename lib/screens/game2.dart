// ignore_for_file: avoid_print

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
String? myName, myIP, myGameType;

class GamePlay extends StatefulWidget {
  const GamePlay({ Key? key }) : super(key: key);

  @override
  State<GamePlay> createState() => _GamePlayState();
}

class _GamePlayState extends State<GamePlay> {
  Map<String, bool> status = {'showGameVariants': true, 'connectionEstablished': false, 'inWaitingRoom': false};
  dynamic res;
  //bool connectionEstablished = false;
  int ticksWaiting = 0;
  List<String> otherPlayersNames = [];

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
    //print('res type: ' + res.runtimeType.toString());
    if (res is IOWebSocketChannel) {
      _connection = res;
      //print('_connection inner exts: ' + _connection!.innerWebSocket!.extensions);
    }
    if (_connection?.innerWebSocket != null) {
      print('connected to server...');
      _connection?.stream.listen((data) => handleData(data),);
      setState(() {
        status['inWaitingRoom'] = true;
        status['connectionEstablished'] = true;
        timer.cancel();
        sendHandshake();
      });
    }
    setState(() {
      ticksWaiting = timer.tick;
    });
  }

  void sendHandshake() async {
    //String data;
    var prefs = await SharedPreferences.getInstance();
    print('stored data: ${prefs.getString('setup')}');
    String name = jsonDecode(prefs.getString('setup')!)['setup']['name'];
    String email = jsonDecode(prefs.getString('setup')!)['setup']['email'];
    var data = jsonEncode({'handshake': {'name': name, 'email': email}});
    _connection?.sink.add(data);
    
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
    if (status['inWaitingRoom']!) {
      return WaitingRoom(gameType: myGameType!, coPlayers: otherPlayersNames,);
    }
    if (status['connectionEstablished']!) {
      return GameWidget(game: _toyTanksGame,);
    } else {
      return Material(child: Center(
          child: Text('(${(10 - ticksWaiting / 10).ceil()}) connecting...'),
          ));
    } 
  }

  handleData(data) {
    print(data);
    try {
      Map<String, dynamic> message = jsonDecode(data);
      switch (message.keys.toList()[0]) {
        case 'userJoinedGame':
          String gotName = message['userJoinedGame'];
          if (gotName != myName) {
            setState(() {
              otherPlayersNames.add(gotName);
            });
          }
          break;
        default:
      }
    } catch (e) {
      print(e);
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
    myGameType = s;
    _connection?.sink.add(jsonEncode({'wantGame$s': ''}));
    callback();
  }
}

class WaitingRoom extends StatefulWidget {
  const WaitingRoom({ Key? key, required this.gameType, required this.coPlayers }) : super(key: key);

  final String gameType;
  final List<String> coPlayers;

  @override
  State<WaitingRoom> createState() => _WaitingRoomState();
}

class _WaitingRoomState extends State<WaitingRoom> {
  @override
  Widget build(BuildContext context) {
    print('waiting room: ${widget.gameType} (${widget.coPlayers})');
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 50),
              child: Text(
                '${widget.gameType} Fight',
                style: TextStyle(
                  color: Colors.amber[400]
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Text(
                'Players:',
                style: TextStyle(
                  color: Colors.amber[400]
                ),
              ),
            ),
            Column(
              children: widget.coPlayers.map((name) => Text(name, style: const TextStyle(color: Colors.green),)).toList(),
            )
          ],
        ),
      )
    );
  }
}

class ToyTanksGame extends FlameGame {
  
}