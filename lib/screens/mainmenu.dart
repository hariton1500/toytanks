import 'package:flutter/material.dart';
import 'package:toytanks/screens/game2.dart';

class MainMenu extends StatelessWidget {
  const MainMenu({ Key? key }) : super(key: key);

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
            ElevatedButton(
              onPressed: () => Navigator.of(context).pushReplacement(MaterialPageRoute(builder: ((context) => const GamePlay()))),
              child: const Text('Setup')
            )
          ],
        ),
      ),
    );
  }
}