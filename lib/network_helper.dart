import 'package:wifi/wifi.dart';
import 'calculation_question.dart';
import 'dart:io';
import 'dart:convert';
import 'user.dart';
import 'round.dart';

typedef void GotQuestionOverUDP(CalculationQuestion question);
typedef void GotRoundOverUDP(Round round);
typedef void GotUserOverUDP(User user);

Future<String> getIp() async {
  return await Wifi.ip;
}

Future<String> getBroadcastAddress() async {
  String ip = await Wifi.ip;
  var lastDot = ip.lastIndexOf('.');
  return ip.substring(0, lastDot) + '.255';
}

RawDatagramSocket _socket;
InternetAddress _address;

void disconnectSocket() {
  _socket.close();
  _socket = null;
}

Future<void> setupUdpListener(GotQuestionOverUDP onQuestion,
    GotRoundOverUDP onRound, GotUserOverUDP onUser) async {
  if (_socket == null) {
    var bcast = await getBroadcastAddress();
    _address = InternetAddress(bcast);

    _socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 1337);
    _socket.multicastHops = 20;
    _socket.broadcastEnabled = true;
    _socket.writeEventsEnabled = true;

    _socket.listen((RawSocketEvent event) {
      if (event == RawSocketEvent.read) {
        final datagramPacket = _socket.receive();
        if (datagramPacket == null) return;
        var stringData = utf8.decode(datagramPacket.data);
        var jsonMap = jsonDecode(stringData);
        if (jsonMap['mode'] != null)
          onQuestion(CalculationQuestion.fromJson(jsonMap));
        else if (jsonMap['winner'] != null) {
          onRound(Round.fromJson(jsonMap));
        } else if (jsonMap['name'] != null) {
          onUser(User.fromJson(jsonMap));
        }
      }
    });
  }
}

int sendData(String data) {
  return _socket.send(utf8.encode(data), _address, 1337);
}

void sendUser(User user) {
  try {
    sendData(jsonEncode(user.toJson()));
  } catch (e) {
    print(e);
  }
}

void sendRound(Round round) {
  try {
    sendData(jsonEncode(round.toJson()));
  } catch (e) {
    print(e);
  }
}

void sendQuestion(CalculationQuestion question) {
  try {
    sendData(jsonEncode(question.toJson()));
  } catch (e) {
    print(e);
  }
}
