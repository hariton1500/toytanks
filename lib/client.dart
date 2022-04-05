
import 'package:web_socket_channel/io.dart';
//import 'package:web_socket_channel/web_socket_channel.dart';
//import 'package:web_socket_channel/status.dart' as status;

dynamic startConnection() {
  return IOWebSocketChannel.connect(Uri.parse('ws://localhost:8000'));
}