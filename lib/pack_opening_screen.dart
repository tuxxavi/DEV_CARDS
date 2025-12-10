// ignore_for_file: use_build_context_synchronously, non_constant_identifier_names

import 'dart:async';
import 'dart:math';

import 'package:dev_cards/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:dev_cards/deck_selection_screen.dart';
import 'package:dev_cards/game_card.dart';
import 'package:dev_cards/game_manager.dart';
import 'package:dev_cards/mini_card_back.dart';
import 'package:dev_cards/particle_explosion_layer.dart';
import 'package:dev_cards/pokemon_style_card.dart';

class PackOpeningScreen extends StatefulWidget {
  final bool isVictory;
  final bool isOnline;
  const PackOpeningScreen({
    super.key,
    required this.isVictory,
    this.isOnline = false,
  });
  @override
  State<PackOpeningScreen> createState() => _PackOpeningScreenState();
}

class _PackOpeningScreenState extends State<PackOpeningScreen>
    with TickerProviderStateMixin {
  final int NUM_CARDS_SORPRES = 1;
  bool isOpened = false;
  List<GameCard> newCards = [];
  late AnimationController _shakeController;
  late Animation<double> _shakeAnim;
  // Controladores para la revelación secuencial
  late List<bool> _isCardRevealed;
  final StreamController<Offset> _confettiCtrl =
      StreamController<Offset>.broadcast();

  @override
  void initState() {
    super.initState();
    final random = Random();
    newCards = List.generate(
      NUM_CARDS_SORPRES,
      (index) =>
          GameManager.allCardsMaster[random.nextInt(
            GameManager.allCardsMaster.length,
          )],
    );
    _isCardRevealed = List.filled(NUM_CARDS_SORPRES, false);

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _shakeAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 15.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 15.0, end: -15.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -15.0, end: 15.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 15.0, end: 0.0), weight: 1),
    ]).animate(_shakeController);

    if (widget.isVictory) {
      // Lanzar confeti al inicio si ganó
      Future.delayed(const Duration(milliseconds: 500), () {
        _confettiCtrl.add(MediaQuery.of(context).size.center(Offset.zero));
      });
    }
  }

  @override
  void dispose() {
    _shakeController.dispose();
    _confettiCtrl.close();
    super.dispose();
  }

  void _openPack() async {
    await _shakeController.forward();
    setState(() {
      isOpened = true;
      GameManager.addToAlbum(newCards);
    });
    // Explosión de partículas al abrir
    _confettiCtrl.add(MediaQuery.of(context).size.center(Offset.zero));
    // Revelar cartas una por una
    for (int i = 0; i < NUM_CARDS_SORPRES; i++) {
      await Future.delayed(const Duration(milliseconds: 400));
      setState(() {
        _isCardRevealed[i] = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101010),
      body: Stack(
        children: [
          const Positioned.fill(
            child: AmbientParticles(),
          ), // Partículas de fondo
          if (widget.isVictory)
            ParticleExplosionLayer(
              triggerStream: _confettiCtrl.stream,
            ), // Confeti si gana
          Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    child: Text(
                      widget.isVictory
                          ? AppLocalizations.of(context)!.victory
                          : AppLocalizations.of(context)!.game_over,
                      key: ValueKey(widget.isVictory),
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: widget.isVictory
                            ? Colors.greenAccent
                            : Colors.grey,
                        shadows: [
                          Shadow(
                            color: widget.isVictory
                                ? Colors.green
                                : Colors.black,
                            blurRadius: 15,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  if (!isOpened)
                    GestureDetector(
                      onTap: _openPack,
                      child: AnimatedBuilder(
                        animation: _shakeAnim,
                        builder: (ctx, child) => Transform.translate(
                          offset: Offset(_shakeAnim.value, 0),
                          child: child,
                        ),
                        child: Container(
                          width: 220,
                          height: 320,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0xFFFFD700),
                                Color(0xFFFFA500),
                                Color(0xFFFF8C00),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.orangeAccent,
                                blurRadius: 30,
                                spreadRadius: 5,
                              ),
                            ],
                            border: Border.all(color: Colors.white54, width: 2),
                          ),
                          child: const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.stars,
                                  size: 80,
                                  color: Colors.white,
                                ),
                                SizedBox(height: 20),
                                Text(
                                  "SOBRE ÉPICO",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 22,
                                    shadows: [
                                      Shadow(
                                        blurRadius: 10,
                                        color: Colors.orange,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    )
                  else
                    Column(
                      children: [
                        const Text(
                          "¡NUEVAS CARTAS!",
                          style: TextStyle(
                            color: Colors.amber,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 15,
                          runSpacing: 15,
                          children: List.generate(newCards.length, (index) {
                            // Animación de Flip para cada carta
                            return AnimatedSwitcher(
                              duration: const Duration(milliseconds: 600),
                              transitionBuilder:
                                  (Widget child, Animation<double> animation) {
                                    final rotateAnim = Tween(
                                      begin: pi,
                                      end: 0.0,
                                    ).animate(animation);
                                    return AnimatedBuilder(
                                      animation: rotateAnim,
                                      child: child,
                                      builder: (context, widget) {
                                        final isUnder =
                                            (ValueKey(_isCardRevealed[index]) !=
                                            widget?.key);
                                        final value = isUnder
                                            ? min(rotateAnim.value, pi / 2)
                                            : rotateAnim.value;
                                        return Transform(
                                          transform: Matrix4.rotationY(value)
                                            ..setEntry(3, 2, 0.001),
                                          alignment: Alignment.center,
                                          child: widget,
                                        );
                                      },
                                    );
                                  },
                              child: _isCardRevealed[index]
                                  ? Transform.scale(
                                      scale: 0.85,
                                      child: PokemonStyleCard(
                                        card: newCards[index],
                                      ),
                                    )
                                  : Transform.scale(
                                      scale: 0.85,
                                      child: const MiniCardBack(),
                                    ),
                            );
                          }),
                        ),
                        const SizedBox(height: 40),
                        const SizedBox(height: 40),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.greenAccent,
                                foregroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 15,
                                ),
                              ),
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => DeckSelectionScreen(
                                      isOnline: widget.isOnline,
                                    ),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.refresh),
                              label: Text(
                                widget.isOnline ? "VENGANZA" : "REJUGAR",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 20),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.cyanAccent,
                                foregroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 15,
                                ),
                              ),
                              onPressed: () => Navigator.of(
                                context,
                              ).popUntil((route) => route.isFirst),
                              icon: const Icon(Icons.home),
                              label: const Text(
                                "MENU",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
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
