import 'package:web_socket_channel/io.dart';
//import 'package:web_socket_channel/web_socket_channel.dart';
//import 'package:web_socket_channel/status.dart' as status;

dynamic startConnection() {
  var temp = IOWebSocketChannel.connect(Uri.parse('ws://192.168.88.197:8000/'));
  return temp;
}
