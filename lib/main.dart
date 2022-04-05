import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:toytanks/client.dart';
//import 'package:toytanks/screens/game.dart';
import 'package:toytanks/screens/gameflame.dart';
import 'package:toytanks/screens/onserver.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final game = ToyTanksGame();
  runApp(GameWidget(game: game));
}

class ToyTanksGame extends FlameGame {
  @override
  Future<void> onLoad() async {
    unawaited(add(Menu()));
  }
}
