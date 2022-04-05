import 'dart:async';

import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:toytanks/client.dart';
import 'package:toytanks/main.dart';

ToyTanksGame _toyTanksGame = ToyTanksGame();

class GamePlay extends StatefulWidget {
  const GamePlay({ Key? key }) : super(key: key);

  @override
  State<GamePlay> createState() => _GamePlayState();
}

class _GamePlayState extends State<GamePlay> {
  
  dynamic _connection;

  @override
  void initState() {
    super.initState();
    _connection = startConnection();
    Timer.periodic(const Duration(milliseconds: 100), checkConnection());
  }

  @override
  Widget build(BuildContext context) {
    return GameWidget(
      game: _toyTanksGame,
    );
  }
}