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
  static int _port = 4040; // Default port

  static Future<String?> getIpAddress() async {
    final info = NetworkInfo();
    var wifiIP = await info.getWifiIP();
    if (wifiIP != null) return wifiIP;

    // Fallback using dart:io
    try {
      final interfaces = await NetworkInterface.list(
        type: InternetAddressType.IPv4,
      );
      for (var interface in interfaces) {
        // Filter out loopback and likely internal interfaces
        if (interface.name.toLowerCase().contains('wlan') ||
            interface.name.toLowerCase().contains('eth') ||
            interface.name.toLowerCase().contains('en0')) {
          return interface.addresses.first.address;
        }
      }
      return interfaces.firstOrNull?.addresses.first.address;
    } catch (e) {
      return null;
    }
  }

  static String generateJoinKey(String ip) {
    try {
      List<int> ipParts = ip.split('.').map(int.parse).toList();
      List<int> bytes = [...ipParts, (_port >> 8) & 0xFF, _port & 0xFF];
      // Base64 encode returns ~8 chars for 6 bytes
      return base64Url.encode(bytes).replaceAll('=', '');
    } catch (e) {
      return "ERROR";
    }
  }

  static Map<String, dynamic>? decodeJoinKey(String key) {
    try {
      // Add padding back if needed for standard decoder, though base64Url usually handles it
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

  // Host a game
  static Future<void> startHosting(Function(bool) onConnected) async {
    stop(); // Close existing
    try {
      _server = await HttpServer.bind(InternetAddress.anyIPv4, _port);
      print("Server running on port $_port");
      _server!.listen((HttpRequest request) async {
        if (request.uri.path == '/ws') {
          // Upgrade to WebSocket
          var socket = await WebSocketTransformer.upgrade(request);
          print("Client connected");
          _handleConnection(socket, onConnected);
        } else {
          request.response.write("ZitroCards Server");
          request.response.close();
        }
      });
    } catch (e) {
      print("Error binding server: $e");
      // Try next port if blocked
      _port++;
      await startHosting(onConnected);
    }
  }

  // Join a game
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
