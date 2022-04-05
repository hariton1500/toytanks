import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import 'package:toytanks/main.dart';

class MenuElement extends TextComponent with Tappable {
  MenuElement({required String text}) : super(text: text);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
  }

  @override
  bool onTapDown(TapDownInfo info) {
    debugPrint('menu pressed');
    debugPrint(info.eventPosition.game.toString());
    //function(info);
    handle(info);
    return true;
  }
}