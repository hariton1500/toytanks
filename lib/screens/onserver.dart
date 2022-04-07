// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

class OnServerScreen extends StatefulWidget {
  final Socket socket;
  final StreamSubscription subscription;
  const OnServerScreen({ Key? key, required this.socket, required this.subscription }) : super(key: key);

  @override
  State<OnServerScreen> createState() => _OnServerScreenState();
}

class _OnServerScreenState extends State<OnServerScreen> {
  
  List<Map<String, dynamic>> rooms = [];

  @override
  void initState() {
    super.initState();
    widget.subscription.onData((data) {handle(data);});
    //widget.socket.cast<List<int>>().transform(utf8.decoder).listen((event) { });
    getRooms(widget.socket);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: <Widget>[
            const Text('Rooms:'),
            rooms.isNotEmpty ?
            ListView.builder(itemBuilder: ((context, index) {
              return ListTile(
                title: rooms[index]['name'],
              );
            })) : const Text('no rooms yet')
          ]
        ),
      ),
      persistentFooterButtons: [
        TextButton.icon(onPressed: (() {
          widget.socket.write('create room');
          sleep(const Duration(milliseconds: 100));
          getRooms(widget.socket);
        }), icon: const Icon(Icons.add_box_outlined), label: const Text('Create Room')),
        TextButton.icon(onPressed: (() {
          getRooms(widget.socket);
          //widget.socket.write('create room');
        }), icon: const Icon(Icons.refresh_outlined), label: const Text('Refresh')),
        TextButton.icon(onPressed: (() {
          Navigator.of(context).pop();
        }), icon: const Icon(Icons.backspace_outlined), label: const Text('Back')),
      ],
    );
  }

  void getRooms(Socket socket) {
    try {
      socket.write('get rooms list');
    } catch (e) {
      print(e);
    }
  }

  void handle(String text) {
    if (text.startsWith('rooms list')) {
      var res = jsonDecode(text.split('||')[1]);
      if (res is List) {
        setState(() {
          rooms = res.cast<Map<String, dynamic>>();
          print(rooms);
        });
      }
    }
  }
}