import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import 'package:toytanks/client.dart';
//import 'package:toytanks/screens/game.dart';
import 'package:toytanks/screens/gameflame.dart';
import 'package:toytanks/screens/menu.dart';
import 'package:toytanks/screens/onserver.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final game = ToyTanksGame();
  runApp(GameWidget(game: game));
}

void handle(TapDownInfo info) {
  debugPrint('sfsdf');
}

class ToyTanksGame extends FlameGame with HasTappables{
  @override
  Future<void> onLoad() async {
    List<MenuElement> menu = [];
    menu.add(MenuElement(text: 'menu one')
      ..anchor = Anchor.topCenter
      ..x = size.x / 2
      ..y = 30);
    menu.add(MenuElement(text: 'menu two')
      ..anchor = Anchor.topCenter
      ..x = size.x / 2
      ..y = 60);
    menu.add(MenuElement(text: 'menu three')
      ..anchor = Anchor.topCenter
      ..x = size.x / 2
      ..y = 90);
    unawaited(addAll(menu));
  }
}
