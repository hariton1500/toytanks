import 'dart:async';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:toytanks/screens/mainmenu.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //final game = ToyTanksGame();
  runApp(MaterialApp(
    themeMode: ThemeMode.dark,
    darkTheme: ThemeData.dark().copyWith(
      textTheme: GoogleFonts.bungeeInlineTextTheme(),
      scaffoldBackgroundColor: Colors.black,
      primaryTextTheme: const TextTheme(
        bodyText1: TextStyle(
          color: Colors.green
        )
      )
    ),
    home: const MainMenu(),
  ));
}

void handle(TapDownInfo info) {
  debugPrint('sfsdf');
}

