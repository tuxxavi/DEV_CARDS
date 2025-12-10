// ignore_for_file: deprecated_member_use

import 'package:dev_cards/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dev_cards/deck_selection_screen.dart';
import 'package:dev_cards/server_manager.dart';
import 'package:dev_cards/stadium_background.dart';

class MultiplayerScreen extends StatefulWidget {
  const MultiplayerScreen({super.key});

  @override
  State<MultiplayerScreen> createState() => _MultiplayerScreenState();
}

class _MultiplayerScreenState extends State<MultiplayerScreen> {
  bool _isHosting = false;
  bool _isJoining = false;
  String _statusMessage = "";
  String? _generatedKey;
  final TextEditingController _keyController = TextEditingController();
  bool _isLoading = false;

  void _reset() {
    setState(() {
      _isHosting = false;
      _isJoining = false;
      _statusMessage = "";
      _generatedKey = null;
      _isLoading = false;
      ServerManager.stop();
    });
  }

  void _onConnected(bool success) {
    if (success) {
      if (!mounted) return;
      setState(() {
        _statusMessage = AppLocalizations.of(context)!.connected_starting;
        _isLoading = false;
      });

      // Delay to show connected message
      Future.delayed(const Duration(seconds: 1), () {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const DeckSelectionScreen(isOnline: true),
          ),
        );
      });
    } else {
      if (mounted) {
        setState(() {
          _statusMessage = "Error de conexión o desconectado.";
          _isLoading = false;
        });
      }
    }
  }

  void _startHosting() async {
    setState(() {
      _isHosting = true;
      _isLoading = true;
      _statusMessage = "Obteniendo IP...";
    });

    String? ip = await ServerManager.getIpAddress();
    if (ip == null) {
      setState(() {
        _statusMessage = "No se pudo obtener IP. Conéctate a WiFi.";
        _isLoading = false;
      });
      return;
    }

    String key = ServerManager.generateJoinKey(ip);

    setState(() {
      _generatedKey = key;
      _statusMessage = "Esperando oponente...";
    });

    ServerManager.startHosting((success) => _onConnected(success));
  }

  void _joinGame() async {
    if (_keyController.text.isEmpty) return;

    setState(() {
      _isLoading = true;
      _statusMessage = "Conectando...";
    });

    bool success = await ServerManager.joinGame(_keyController.text.trim(), (
      connected,
    ) {
      _onConnected(connected);
    });

    if (!success) {
      setState(() {
        _statusMessage = "Clave inválida o host no encontrado.";
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("MULTIPLAYER 1VS1"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            ServerManager.stop();
            Navigator.pop(context);
          },
        ),
      ),
      body: Stack(
        children: [
          const Positioned.fill(child: StadiumBackground(animate: false)),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (!_isHosting && !_isJoining) ...[
                    _buildMainMenu(),
                  ] else if (_isHosting) ...[
                    _buildHostView(),
                  ] else if (_isJoining) ...[
                    _buildJoinView(),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainMenu() {
    return Column(
      children: [
        _BigButton(
          label: AppLocalizations.of(context)!.create_game,
          icon: Icons.wifi_tethering,
          color: Colors.purpleAccent,
          onTap: _startHosting,
        ),
        const SizedBox(height: 30),
        _BigButton(
          label: AppLocalizations.of(context)!.search_game,
          icon: Icons.search,
          color: Colors.blueAccent,
          onTap: () {
            setState(() {
              _isJoining = true;
            });
          },
        ),
      ],
    );
  }

  Widget _buildHostView() {
    return Column(
      children: [
        Text(
          AppLocalizations.of(context)!.your_access_key,
          style: const TextStyle(fontSize: 18, color: Colors.white70),
        ),
        const SizedBox(height: 10),
        if (_generatedKey != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.purpleAccent),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SelectableText(
                  _generatedKey!,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                    color: Colors.greenAccent,
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  icon: const Icon(Icons.copy, color: Colors.white70),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: _generatedKey!));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(AppLocalizations.of(context)!.key_copied),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        const SizedBox(height: 10),
        if (_generatedKey != null)
          Text(
            "IP: ${ServerManager.decodeJoinKey(_generatedKey!)?['ip'] ?? 'Unknown'}",
            style: const TextStyle(color: Colors.white30, fontSize: 12),
          ),
        const SizedBox(height: 30),
        if (_isLoading)
          const CircularProgressIndicator(color: Colors.purpleAccent),
        const SizedBox(height: 20),
        Text(_statusMessage, style: const TextStyle(color: Colors.white70)),
        const SizedBox(height: 40),
        TextButton.icon(
          label: Text(AppLocalizations.of(context)!.cancel),
          icon: const Icon(Icons.cancel),
          style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
          onPressed: _reset,
        ),
      ],
    );
  }

  Widget _buildJoinView() {
    return Column(
      children: [
        Text(
          AppLocalizations.of(context)!.enter_key,
          style: const TextStyle(fontSize: 18, color: Colors.white70),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: 300,
          child: TextField(
            controller: _keyController,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              letterSpacing: 2,
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.black54,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.blueAccent),
                borderRadius: BorderRadius.circular(10),
              ),
              hintText: "Clave...",
              hintStyle: const TextStyle(color: Colors.white24),
            ),
          ),
        ),
        const SizedBox(height: 30),
        if (_isLoading)
          const CircularProgressIndicator(color: Colors.blueAccent)
        else
          ElevatedButton.icon(
            onPressed: _joinGame,
            icon: const Icon(Icons.link),
            label: const Text("CONECTAR"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
            ),
          ),
        const SizedBox(height: 20),
        Text(_statusMessage, style: const TextStyle(color: Colors.redAccent)),
        const SizedBox(height: 40),
        TextButton.icon(
          label: const Text("Atrás"),
          icon: const Icon(Icons.arrow_back),
          style: TextButton.styleFrom(foregroundColor: Colors.white70),
          onPressed: _reset,
        ),
      ],
    );
  }
}

class _BigButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _BigButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 280,
        padding: const EdgeInsets.symmetric(vertical: 25),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color, width: 2),
          boxShadow: [BoxShadow(color: color.withOpacity(0.3), blurRadius: 20)],
        ),
        child: Column(
          children: [
            Icon(icon, size: 50, color: color),
            const SizedBox(height: 10),
            Text(
              label,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
