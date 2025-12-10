// ignore_for_file: deprecated_member_use

import 'package:dev_cards/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:dev_cards/album_screen.dart';
import 'package:dev_cards/deck_selection_screen.dart';
import 'package:dev_cards/game_manager.dart';
import 'package:dev_cards/multiplayer_screen.dart';
import 'package:dev_cards/particle_explosion_layer.dart';
import 'package:dev_cards/stadium_background.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.immersiveSticky,
  ); // Pantalla completa
  await GameManager.initialize();
  runApp(const IoFlipApp());
}

final ValueNotifier<Locale> localeNotifier = ValueNotifier(
  Locale(GameManager.currentLocale),
);

class IoFlipApp extends StatelessWidget {
  const IoFlipApp({super.key});
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: localeNotifier,
      builder: (context, locale, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'DEV CARDS',
          locale: locale,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'), // English (Default)
            Locale('es'), // Spanish
            Locale('ca'), // Catalan
          ],
          theme: ThemeData.dark().copyWith(
            scaffoldBackgroundColor: const Color(0xFF050505),
            colorScheme: const ColorScheme.dark(primary: Colors.cyanAccent),
          ),
          home: const MainMenuScreen(),
        );
      },
    );
  }
}

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  void _changeLanguage(String code) {
    GameManager.setLocale(code);
    localeNotifier.value = Locale(code);
  }

  void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: Colors.cyanAccent.withOpacity(0.5)),
          ),
          title: Text(
            AppLocalizations.of(context)!.settings,
            style: const TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context)!.language,
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.cyanAccent.withOpacity(0.5)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    dropdownColor: Colors.grey[800],
                    value: GameManager.currentLocale,
                    isExpanded: true,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    iconEnabledColor: Colors.cyanAccent,
                    onChanged: (val) {
                      if (val != null) {
                        _changeLanguage(val);
                        Navigator.pop(ctx);
                      }
                    },
                    items: const [
                      DropdownMenuItem(
                        value: 'en',
                        child: Row(children: [Text("🇬🇧  English")]),
                      ),
                      DropdownMenuItem(
                        value: 'es',
                        child: Row(children: [Text("🇪🇸  Español")]),
                      ),
                      DropdownMenuItem(
                        value: 'ca',
                        child: Row(children: [Text("🏴  Català")]),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text(
                "OK",
                style: TextStyle(color: Colors.cyanAccent),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: StadiumBackground(animate: false)),
          // Partículas ambientales sutiles en el menú
          const Positioned.fill(child: AmbientParticles()),

          // Settings Button (Top Right)
          Positioned(
            top: 40,
            right: 20,
            child: IconButton(
              icon: const Icon(Icons.settings, color: Colors.white, size: 30),
              onPressed: () => _showSettingsDialog(context),
            ),
          ),

          Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TweenAnimationBuilder(
                    tween: Tween<double>(begin: 0, end: 1),
                    duration: const Duration(seconds: 1),
                    curve: Curves.elasticOut,
                    builder: (context, value, child) =>
                        Transform.scale(scale: value, child: child),
                    child: const Icon(
                      Icons.style,
                      size: 100,
                      color: Colors.cyanAccent,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    AppLocalizations.of(context)!.title,
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                      shadows: [Shadow(color: Colors.blue, blurRadius: 20)],
                    ),
                  ),
                  const Text(
                    "ULTIMATE EDITION",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      letterSpacing: 5,
                    ),
                  ),
                  const SizedBox(height: 60),
                  Wrap(
                    spacing: 20,
                    runSpacing: 20,
                    alignment: WrapAlignment.center,
                    children: [
                      _MenuButton(
                        label: AppLocalizations.of(context)!.combat,
                        icon: Icons.snowboarding_sharp,
                        color: Colors.redAccent,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const DeckSelectionScreen(),
                          ),
                        ),
                      ),
                      _MenuButton(
                        label: AppLocalizations.of(context)!.online,
                        icon: Icons.wifi,
                        color: Colors.purpleAccent,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const MultiplayerScreen(),
                          ),
                        ),
                      ),
                      _MenuButton(
                        label:
                            "${AppLocalizations.of(context)!.album} (${GameManager.userAlbum.length})",
                        icon: Icons.collections_bookmark,
                        color: Colors.blueAccent,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AlbumScreen(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _MenuButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });
  @override
  State<_MenuButton> createState() => _MenuButtonState();
}

class _MenuButtonState extends State<_MenuButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.95).animate(_controller);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnim,
        builder: (context, child) =>
            Transform.scale(scale: _scaleAnim.value, child: child),
        child: Container(
          width: 250,
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: widget.color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: widget.color, width: 2),
            boxShadow: [
              BoxShadow(color: widget.color.withOpacity(0.3), blurRadius: 20),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.icon, color: widget.color),
              const SizedBox(width: 15),
              Text(
                widget.label,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
