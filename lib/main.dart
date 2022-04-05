import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:toytanks/client.dart';
//import 'package:toytanks/screens/game.dart';
import 'package:toytanks/screens/gameflame.dart';
import 'package:toytanks/screens/onserver.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: ''),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  Socket? socket;
  WebSocket? ws;
  String? gameStatus;
  bool isServerOk = false;
  ClientWS? clientWS;
  
  @override
  void initState() {
    super.initState();
    clientWS = ClientWS();
    ws = clientWS?.webSocket;
    /*
    startTCPClient().then((value) {
      if (socket != null) {
        socket = value;
        subscription = socket!.cast<List<int>>().transform(utf8.decoder).listen(handle);
      } else {
        debugPrint('socket is null');
      }
    });*/
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextButton(
              onPressed:  isServerOk ? () => send('connect to server?') : null,//connectToServer(),
              child: Text(isServerOk ? 'Connect to Toytanks...' : 'Game server is unrichable :(')
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (() => Navigator.push(context, MaterialPageRoute(builder: (context) => GameWidget(game: MyGame(ws!),)),)),
        tooltip: 'ToyScreen',
        child: const Icon(Icons.games),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
  
  void send(String text) {
    try {
      debugPrint('=>$text');
      socket!.write(text);
    } catch (e) {
      debugPrint('send: $e');
    }
  }

  Future<dynamic> startTCPClient() async {
    try {
      debugPrint('client: [startTCPClient]');
      socket = await Socket.connect(InternetAddress.loopbackIPv4, 5555);
      debugPrint('=>Hello, Server!');
      socket!.write('Hello, Server!');
      setState(() {
        isServerOk = true;
      });
      return socket!;
    } catch (e) {
      setState(() {
        isServerOk = false;
      });
      debugPrint('startTCPClient: $e');
    }
  }

  void handle(String text) {
    debugPrint('<=$text');
    switch (text) {
      case 'you are connected':
        //subscription!.cancel();
        //Navigator.push(context, MaterialPageRoute(builder: (context) => OnServerScreen(socket: socket!, subscription: ws!,)),);
        break;
      case '':
        
        break;
      default:
    }
  }
}
