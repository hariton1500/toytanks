import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toytanks/screens/game2.dart';
import 'package:toytanks/screens/setup.dart';

class MainMenu extends StatefulWidget {
  const MainMenu({ Key? key }) : super(key: key);

  @override
  State<MainMenu> createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {

  Map<String, dynamic> setup = {};

  @override
  void initState() {
    super.initState();
    startChecks();
  }

  void startChecks() async {
    final prefs = await SharedPreferences.getInstance();
    try {
      if (prefs.getKeys().contains('setup')) {
        setup = jsonDecode(prefs.getString('setup')!);
      } else {
        Navigator.of(context).push(MaterialPageRoute(builder: (context) => const SetupPage()));
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 50.0),
              child: Text(
                'Toy Tanks',
                style: Theme.of(context)
                  .textTheme
                  .bodyText1
                  ?.copyWith(
                    fontSize: 50.0,
                    shadows: [
                      const Shadow(
                        blurRadius: 20.0,
                        color: Colors.white,
                        offset: Offset.zero
                      )
                    ]
                  ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pushReplacement(MaterialPageRoute(builder: ((context) => const GamePlay()))),
              child: const Text('Play')
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pushReplacement(MaterialPageRoute(builder: ((context) => const SetupPage()))),
                child: const Text('Setup')
              ),
            )
          ],
        ),
      ),
    );
  }
}