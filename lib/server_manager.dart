// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:network_info_plus/network_info_plus.dart';

class ServerManager {
  static HttpServer? _server;
  static WebSocket? _socket;
  static final StreamController<String> _dataStream =
      StreamController.broadcast();
  static bool get isConnected => _socket != null;
  static Stream<String> get onData => _dataStream.stream;
  static int _port = 4040;

  static Future<String?> getIpAddress() async {
    if (Platform.isAndroid || Platform.isIOS) {
      final info = NetworkInfo();
      try {
        var wifiIP = await info.getWifiIP();
        if (wifiIP != null && wifiIP.isNotEmpty) return wifiIP;
      } catch (e) {
        print("Error fetching Wifi IP: $e");
      }
    }

    try {
      final interfaces = await NetworkInterface.list(
        type: InternetAddressType.IPv4,
      );

      String? bestIp;
      String? fallbackIp;

      for (var interface in interfaces) {
        print("Found interface: ${interface.name}");
        for (var addr in interface.addresses) {
          print("  - IP: ${addr.address}");
          if (addr.address.startsWith('192.168.')) {
            return addr.address;
          }
          if (!addr.isLoopback && !addr.address.startsWith('127.')) {
            if (bestIp == null && !addr.address.startsWith('10.0.2.')) {
              bestIp = addr.address;
            }
            fallbackIp ??= addr.address;
          }
        }
      }

      return bestIp ?? fallbackIp;
    } catch (e) {
      print("Error detecting IP: $e");
      return null;
    }
  }

  static String generateJoinKey(String ip) {
    try {
      List<int> ipParts = ip.split('.').map(int.parse).toList();
      List<int> bytes = [...ipParts, (_port >> 8) & 0xFF, _port & 0xFF];
      return base64Url.encode(bytes).replaceAll('=', '');
    } catch (e) {
      return "ERROR";
    }
  }

  static Map<String, dynamic>? decodeJoinKey(String key) {
    try {
      String normalized = key;
      while (normalized.length % 4 != 0) {
        normalized += '=';
      }
      List<int> bytes = base64Url.decode(normalized);
      if (bytes.length < 6) return null;

      String ip = "${bytes[0]}.${bytes[1]}.${bytes[2]}.${bytes[3]}";
      int port = (bytes[4] << 8) | bytes[5];

      return {'ip': ip, 'port': port};
    } catch (e) {
      return null;
    }
  }

  static Future<void> startHosting(
    Function(bool) onConnected, {
    int retries = 0,
  }) async {
    stop();
    if (retries > 10) {
      print("Failed to bind server after 10 retries.");
      onConnected(false);
      return;
    }

    try {
      _server = await HttpServer.bind(InternetAddress.anyIPv4, _port);
      print("Server running on port $_port");
      _server!.listen((HttpRequest request) async {
        if (request.uri.path == '/ws') {
          var socket = await WebSocketTransformer.upgrade(request);
          print("Client connected");
          _handleConnection(socket, onConnected);
        } else {
          request.response.write("ZitroCards Server");
          request.response.close();
        }
      });
    } catch (e) {
      print("Error binding server on port $_port: $e");
      _port++;
      await startHosting(onConnected, retries: retries + 1);
    }
  }

  static Future<bool> joinGame(String key, Function(bool) onConnected) async {
    stop();
    var data = decodeJoinKey(key);
    if (data == null) return false;

    String ip = data['ip'];
    int port = data['port'];

    try {
      var socket = await WebSocket.connect('ws://$ip:$port/ws');
      print("Connected to host");
      _handleConnection(socket, onConnected);
      return true;
    } catch (e) {
      print("Connection failed: $e");
      return false;
    }
  }

  static void _handleConnection(WebSocket socket, Function(bool) onConnected) {
    _socket = socket;

    socket.listen(
      (data) {
        _dataStream.add(data.toString());
      },
      onDone: () {
        print("Disconnected");
        onConnected(false);
        _socket = null;
      },
      onError: (e) {
        print("Error: $e");
        onConnected(false);
        _socket = null;
      },
    );

    onConnected(true);
  }

  static void send(String message) {
    if (_socket != null) {
      _socket!.add(message);
    }
  }

  static void stop() {
    try {
      if (_server != null) {
        _server!.close();
        _server = null;
      }
      if (_socket != null) {
        _socket!.close();
        _socket = null;
      }
    } catch (e) {
      print("Error stopping: $e");
    }
  }
}
