import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toytanks/screens/mainmenu.dart';

class SetupPage extends StatefulWidget {
  const SetupPage({ Key? key }) : super(key: key);

  @override
  State<SetupPage> createState() => _SetupPageState();
}

class _SetupPageState extends State<SetupPage> {
  
  String status = '';
  String name = '';
  String email = '';
  String password = '';

  @override
  Widget build(BuildContext context) {
    if (status == 'nep') {
      saveSetup();
      Timer(const Duration(seconds: 1), () => Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const MainMenu())));
      return Scaffold(
        body: Container(),
      );
    } else {
      return Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20.0),
                  child: TextField(
                    style: const TextStyle(
                      color: Color.fromARGB(255, 21, 116, 24)
                    ),
                    obscureText: false,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Name',
                    ),
                    onSubmitted: (text) {
                      setState(() {
                        name = text;
                        status = 'n';
                      });
                    },
                  ),
                ),
              status == 'n' ?
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20.0),
                  child: TextField(
                    style: const TextStyle(
                      color: Colors.green
                    ),
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Email',
                    ),
                    keyboardType: TextInputType.emailAddress,
                    onSubmitted: (text) {
                      setState(() {
                        email = text;
                        status = 'ne';
                      });
                    },
                  ),
                )
              : Container(),
              status == 'ne' ?
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20.0),
                  child: TextField(
                    style: const TextStyle(
                      color: Colors.green
                    ),
                    obscureText: true,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Password',
                    ),
                    onSubmitted: (text) {
                      setState(() {
                        password = text;
                        status = 'nep';
                      });
                    },
                  ),
                )
              : Container()
              ],
            )
          ),
        ),
      );
    }
  }

  saveSetup() async {
    var prefs = await SharedPreferences.getInstance();
    prefs.setString('setup', jsonEncode({'setup': {'name': name, 'email': email, 'passwd': password}}));
  }
}