// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:convert';

import 'package:flame/components.dart' hide Timer;
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toytanks/client.dart';
import 'package:toytanks/screens/mainmenu.dart';
import 'package:web_socket_channel/io.dart';

ToyTanksGame _toyTanksGame = ToyTanksGame();
IOWebSocketChannel? _connection;
String? myName, myIP, myGameType;
int? myIndex;
List<String>? myMap;
Vector2? myPosition;
List<Vector2>? otherPlayersPos;

class GamePlay extends StatefulWidget {
  const GamePlay({Key? key}) : super(key: key);

  @override
  State<GamePlay> createState() => _GamePlayState();
}

class _GamePlayState extends State<GamePlay> {
  Map<String, bool> status = {
    'showGameVariants': true,
    'connectionEstablished': false,
    'inWaitingRoom': false
  };
  dynamic res;
  //bool connectionEstablished = false;
  int ticksWaiting = 0;
  List<String> otherPlayersNames = [];

  @override
  void initState() {
    super.initState();
    res = startConnection();
    Timer.periodic(
        const Duration(milliseconds: 100), (timer) => checkConnection(timer));
  }

  void checkConnection(Timer timer) {
    if (timer.tick >= 100) {
      timer.cancel();
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const MainMenu()));
    }
    //print('res type: ' + res.runtimeType.toString());
    if (res is IOWebSocketChannel) {
      _connection = res;
      //print('_connection inner exts: ' + _connection!.innerWebSocket!.extensions);
    }
    if (_connection?.innerWebSocket != null) {
      print('connected to server...');
      _connection?.stream.listen(
        (data) => handleData(data),
      );
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
    var data = jsonEncode({
      'handshake': {'name': name, 'email': email}
    });
    _connection?.sink.add(data);
  }

  @override
  Widget build(BuildContext context) {
    //debugPrint('game2 build');
    //debugPrint(status.toString());
    if (status['showGameVariants']!) {
      return GameVariants(
        callback: () {
          setState(() {
            status['showGameVariants'] = false;
          });
        },
      );
    }
    if (status['inWaitingRoom']!) {
      return WaitingRoom(
        gameType: myGameType!,
        coPlayers: otherPlayersNames,
      );
    }
    if (status['connectionEstablished']!) {
      print('entering game');
      return GameWidget(
        game: _toyTanksGame,
        loadingBuilder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else {
      return Material(
          child: Center(
        child: Text('(${(10 - ticksWaiting / 10).ceil()}) connecting...'),
      ));
    }
  }

  handleData(data) {
    //print(data);
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
        case 'map':
          var _map = message['map'];
          if (_map is List) {
            myMap = _map.map((line) => line.toString()).toList();
          }
          print('loaded map:');
          print(myMap);
          break;
        case 'yourIndex':
          setState(() {
            status['inWaitingRoom'] = false;
            myIndex = message['yourIndex'];
            print('myIndex in Map is: $myIndex');
          });
          break;
        case 'position':
          var _position = message['position'];
          //print(_position);
          if (_position is Map) {
            var index = int.parse(_position['index'].toString());
            var position = Vector2(_position['x'], _position['y']);
            var angle = _position['angle'];
            //print('myPosition in Map is: $position');
            _toyTanksGame.setPosition(position, index, angle);
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
  const GameVariants({Key? key, required this.callback}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
                onPressed: () => sendVariant('1x1'),
                child: const Text('1 x 1')),
            ElevatedButton(
                onPressed: () => sendVariant('2x2'),
                child: const Text('2 x 2')),
            ElevatedButton(
                onPressed: () => sendVariant('3x3'),
                child: const Text('3 x 3')),
            ElevatedButton(
                onPressed: () => sendVariant('4x4'),
                child: const Text('4 x 4')),
          ],
        ),
      ),
    );
  }

  sendVariant(String s) {
    myGameType = s;
    _connection?.sink.add(jsonEncode({'wantGame': s}));
    callback();
  }
}

class WaitingRoom extends StatefulWidget {
  const WaitingRoom({Key? key, required this.gameType, required this.coPlayers})
      : super(key: key);

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
              style: TextStyle(color: Colors.amber[400]),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Text(
              'Players:',
              style: TextStyle(color: Colors.amber[400]),
            ),
          ),
          Column(
            children: widget.coPlayers
                .map((name) => Text(
                      name,
                      style: const TextStyle(color: Colors.green),
                    ))
                .toList(),
          )
        ],
      ),
    ));
  }
}

class ToyTanksGame extends FlameGame with KeyboardEvents {
  final List<SpriteComponent> players = [], walls = [];
  SpriteComponent? wall, player;
  //List<PositionComponent> _enemies = [];
  @override
  Future<void> onLoad() async {
    //super.onLoad();
    final wallSprite = await Sprite.load('wall.png');
    final playerSprite = await Sprite.load('tank.png');
    for (var i = 0; i < myMap!.length; i++) {
      String line = myMap![i];
      for (var j = 0; j < line.split('').length; j++) {
        String c = line[j];
        if (c == '=') {
          wall = SpriteComponent(
              anchor: Anchor.center,
              position: Vector2(j * 20 + 10, i * 20 + 10),
              sprite: wallSprite,
              size: Vector2.all(20.0));
          //print(wall!.position.toString());
          walls.add(wall!);
        } else if (c == ' ') {
        } else {
          player = SpriteComponent(
              anchor: Anchor.center,
              sprite: playerSprite,
              position: Vector2(j * 20 + 10, i * 20 + 10),
              size: Vector2(10, 20));
          print(player!.position.toString());
          players.add(player!);
        }
      }
    }
    print('players: ' + players.length.toString());
    addAll(players);
    print('walls: ${walls.length}');
    addAll(walls);
    if (players.isNotEmpty) {
      camera.followComponent(players[myIndex! - 1]);
      camera.zoom = 1;
    }
  }

  @override
  KeyEventResult onKeyEvent(
    RawKeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    final isKeyDown = event is RawKeyDownEvent;

    final isSpace = keysPressed.contains(LogicalKeyboardKey.space);
    final isW = keysPressed.contains(LogicalKeyboardKey.keyW);
    final isS = keysPressed.contains(LogicalKeyboardKey.keyS);
    final isA = keysPressed.contains(LogicalKeyboardKey.keyA);
    final isD = keysPressed.contains(LogicalKeyboardKey.keyD);
    final isLeft = keysPressed.contains(LogicalKeyboardKey.arrowLeft);
    final isRight = keysPressed.contains(LogicalKeyboardKey.arrowRight);

    if (isSpace && isKeyDown) {
      shoot();
      return KeyEventResult.handled;
    }
    if (isW && isKeyDown) {
      print('W');
      speed(1);
      return KeyEventResult.handled;
    }
    if (isS && isKeyDown) {
      speed(-1);
      return KeyEventResult.handled;
    }
    if (isA && isKeyDown) {
      leftRight(-1);
      return KeyEventResult.handled;
    }
    if (isD && isKeyDown) {
      leftRight(1);
      return KeyEventResult.handled;
    }
    if (isLeft && isKeyDown) {
      leftRightGun(-1);
      return KeyEventResult.handled;
    }
    if (isRight && isKeyDown) {
      leftRightGun(1);
      return KeyEventResult.handled;
    }
    if (isSpace && isKeyDown) {
      shoot();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  void setPosition(Vector2 vector2, int index, double angle) {
    if (players.length - 1 >= index) {
      players[index].position = vector2;
      players[index].angle = angle;
    }
  }

  void shoot() {
    _connection?.sink.add(jsonEncode({
      'playerAction': {
        'key': {'shoot': ''}
      }
    }));
  }

  void speed(int i) {
    _connection?.sink.add(jsonEncode({
      'playerAction': {
        'key': {'speed': i}
      }
    }));
  }

  void leftRight(int i) {
    _connection?.sink.add(jsonEncode({
      'playerAction': {
        'key': {'leftRight': i}
      }
    }));
  }

  void leftRightGun(int i) {
    _connection?.sink.add(jsonEncode({
      'playerAction': {
        'key': {'leftRightGun': i}
      }
    }));
  }
  //@override
}

class Wall extends SpriteComponent {
  Wall({required Vector2 pos}) : super(position: pos, size: Vector2.all(20.0));
  @override
  Future<void> onLoad() async {
    await Sprite.load('wall.png');
  }
}

class Player extends SpriteComponent {
  Player({required Vector2 pos})
      : super(position: pos, size: Vector2(20.0, 10.0));
  @override
  Future<void> onLoad() async {
    await Sprite.load('tank.png');
  }
}

class Enemy extends SpriteComponent {
  Enemy({required Vector2 pos})
      : super(position: pos, size: Vector2(20.0, 10.0)) {
    Sprite.load('tank.png');
  }
}
