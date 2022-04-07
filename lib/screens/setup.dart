import 'dart:async';

import 'package:flutter/material.dart';

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
      Timer(const Duration(seconds: 1), () => Navigator.of(context).pop(context));
      return Scaffold(
        body: Container(),
      );
    } else {
      return Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Center(
            child: status == '' ?
              TextField(
                style: const TextStyle(
                  color: Colors.green
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
              )
            : status == 'n' ?
                TextField(
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
                )
              : TextField(
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
                )
          ),
        ),
      );
    }
  }

  saveSetup() {}
}