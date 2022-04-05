import 'dart:io' show HttpServer, HttpRequest, WebSocket, WebSocketTransformer;
import 'dart:convert' show json;
import 'dart:async' show Timer;

main() {
  HttpServer.bind('localhost', 8000).then((HttpServer server) {
    print('[ws+]WebSocket listening at -- ws://localhost:8000/');
    server.listen((HttpRequest request) {
      WebSocketTransformer.upgrade(request).then((WebSocket ws) {
        ws.listen(
          (data) {
            print(
                'ws\t\t${request.connectionInfo!.remoteAddress.address} -- ${Map<String, String>.from(json.decode(data))}');
            Timer(const Duration(milliseconds: 1000~/60), () {
              if (ws.readyState == WebSocket.open) {
                ws.add(json.encode({
                  'data': 'from server at ${DateTime.now().toString()}',
                }));
              }
            });
          },
          onDone: () => print('[ws+]Done :) [${ws.closeReason}]'),
          onError: (err) => print('[ws!]Error -- ${err.toString()}'),
          cancelOnError: true,
        );
      }, onError: (err) => print('[ws!]Error -- ${err.toString()}'));
    }, onError: (err) => print('[ws!]Error -- ${err.toString()}'));
  }, onError: (err) => print('[ws!]Error -- ${err.toString()}'));
}
