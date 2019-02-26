import 'package:wifi/wifi.dart';
import 'calculation_question.dart';
import 'dart:io';
import 'dart:convert';

typedef void gotQuestionOverUDP(CalculationQuestion question);

Future<String> getBroadcastAddress() async {
  String ip = await Wifi.ip;
  var lastDot = ip.lastIndexOf('.');
  return ip.substring(0, lastDot) + '.255';
}

RawDatagramSocket _socket;

Future<void> setupUdpListener(gotQuestionOverUDP onQuestion) async {
  var bcast = await getBroadcastAddress();
  //var _sendAddress = InternetAddress(bcast);
  print(bcast);
  _socket = await RawDatagramSocket.bind(bcast, 1337);
  _socket.multicastHops = 20;
  _socket.broadcastEnabled = true;
  _socket.writeEventsEnabled = true;

  _socket.listen((RawSocketEvent event) {
    if (event == RawSocketEvent.read) {
      final datagramPacket = _socket.receive();
      if (datagramPacket == null) return;
      var stringData = utf8.decode(datagramPacket.data);
      var jsonMap = jsonDecode(stringData);
      onQuestion(CalculationQuestion.fromJson(jsonMap));
    }
  });
}

Future<bool> sendQuestion(CalculationQuestion question) async {
  var addr = InternetAddress(await getBroadcastAddress());
  try {
    var dataString = jsonEncode(question.toJson());
    _socket.send(utf8.encode(dataString), addr, 1337);
  } catch (e) {
    print(e);
  }
}
