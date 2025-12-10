import 'package:dev_cards/l10n/app_localizations.dart';
// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:dev_cards/battle_screen.dart';
import 'package:dev_cards/game_card.dart';
import 'package:dev_cards/game_manager.dart';
import 'package:dev_cards/mini_card_back.dart';
import 'package:dev_cards/pokemon_style_card.dart';
import 'package:dev_cards/server_manager.dart';
import 'package:dev_cards/stadium_background.dart';

class DeckSelectionScreen extends StatefulWidget {
  final bool isOnline;
  const DeckSelectionScreen({super.key, this.isOnline = false});
  @override
  State<DeckSelectionScreen> createState() => _DeckSelectionScreenState();
}

class _DeckSelectionScreenState extends State<DeckSelectionScreen>
    with TickerProviderStateMixin {
  List<GameCard> bench = [];
  late List<GameCard> _upcomingCards;
  Offset _dragOffset = Offset.zero;
  double _dragRotation = 0.0;
  AnimationController? _animController;

  void _fillDeck() {
    final random = Random();
    _upcomingCards = List.generate(
      50,
      (index) =>
          GameManager.allCardsMaster[random.nextInt(
            GameManager.allCardsMaster.length,
          )],
    );
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    setState(() {
      _dragOffset += details.delta;
      _dragRotation = _dragOffset.dx * 0.001;
    });
  }

  void _handlePanEnd(DragEndDetails details) {
    if (_dragOffset.dy > 150) {
      if (bench.length < 3) {
        _addToBench();
      } else {
        _snapBack();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.deck_full),
            duration: const Duration(milliseconds: 500),
          ),
        );
      }
    } else if (_dragOffset.dx.abs() > 100) {
      _discardCard(_dragOffset.dx > 0);
    } else {
      _snapBack();
    }
  }

  void _addToBench() {
    setState(() {
      bench.add(_upcomingCards[0]);
      _upcomingCards.removeAt(0);
      if (_upcomingCards.length < 5) _fillDeck();
      _resetPosition();
    });
  }

  void _discardCard(bool right) {
    final endX = right ? 500.0 : -500.0;
    _runAnimation(Offset(endX, _dragOffset.dy), () {
      setState(() {
        _upcomingCards.removeAt(0);
        if (_upcomingCards.length < 5) _fillDeck();
        _resetPosition();
      });
    });
  }

  void _snapBack() {
    _runAnimation(Offset.zero, () {});
  }

  void _resetPosition() {
    _dragOffset = Offset.zero;
    _dragRotation = 0.0;
  }

  void _runAnimation(Offset target, VoidCallback onComplete) {
    _animController?.dispose();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    final startOffset = _dragOffset;
    final anim = Tween<Offset>(
      begin: startOffset,
      end: target,
    ).animate(CurvedAnimation(parent: _animController!, curve: Curves.easeOut));

    anim.addListener(() {
      setState(() {
        _dragOffset = anim.value;
        _dragRotation = _dragOffset.dx * 0.001;
      });
    });

    anim.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        onComplete();
      }
    });

    _animController!.forward();
  }

  // ignore: unused_element
  void _removeFromBench(int index) {
    setState(() {
      bench.removeAt(index);
    });
  }

  bool _amIReady = false;
  bool _isOpponentReady = false;
  StreamSubscription? _serverSub;

  @override
  void initState() {
    super.initState();
    _fillDeck();
    if (widget.isOnline) {
      _serverSub = ServerManager.onData.listen(_onServerMessage);
    }
  }

  void _onServerMessage(String msg) {
    if (msg.contains("READY")) {
      setState(() {
        _isOpponentReady = true;
      });
      _checkStart();
    }
  }

  void _startGame() {
    if (widget.isOnline) {
      setState(() {
        _amIReady = true;
      });
      ServerManager.send('{"type":"READY"}');
      _checkStart();
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => BattleScreen(playerStartingCards: bench),
        ),
      );
    }
  }

  void _checkStart() {
    if (_amIReady && _isOpponentReady) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
              BattleScreen(playerStartingCards: bench, isOnline: true),
        ),
      );
    }
  }

  @override
  void dispose() {
    _animController?.dispose();
    _serverSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            const Positioned.fill(child: StadiumBackground(animate: false)),
            SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: Center(
                      child: _upcomingCards.isEmpty
                          ? const CircularProgressIndicator()
                          : Stack(
                              alignment: Alignment.center,
                              children: [
                                ...List.generate(
                                  min(6, _upcomingCards.length - 1),
                                  (index) {
                                    final reversedIndex =
                                        min(6, _upcomingCards.length - 1) -
                                        1 -
                                        index;

                                    final scale = 0.9 - (reversedIndex * 0.05);
                                    final yOffset = 15.0 * (reversedIndex + 1);

                                    return Transform.translate(
                                      offset: Offset(0, yOffset),
                                      child: Transform.scale(
                                        scale: scale,
                                        child: const MiniCardBack(),
                                      ),
                                    );
                                  },
                                ),

                                GestureDetector(
                                  onPanUpdate: _handlePanUpdate,
                                  onPanEnd: _handlePanEnd,
                                  child: Transform.translate(
                                    offset: _dragOffset,
                                    child: Transform.rotate(
                                      angle: _dragRotation,
                                      child: PokemonStyleCard(
                                        card: _upcomingCards[0],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),

                  if (bench.length < 3)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        AppLocalizations.of(context)!.instructions_deck,
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ),
                  if (bench.length == 3)
                    Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(AppLocalizations.of(context)!.start_game),
                          SizedBox(width: 10),
                          FloatingActionButton.small(
                            backgroundColor: Colors.cyanAccent,
                            onPressed: _startGame,
                            child: const Icon(
                              Icons.play_arrow,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),

                  Container(
                    height: 220,
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.black45,
                      border: Border(
                        top: BorderSide(color: Colors.white.withOpacity(0.1)),
                      ),
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(3, (index) {
                          if (index < bench.length) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 5,
                              ),
                              child: GestureDetector(
                                onTap: () {}, //_removeFromBench(index),
                                child: PokemonStyleCard(
                                  card: bench[index],
                                  isSmall: true,
                                ),
                              ),
                            );
                          } else {
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 5,
                              ),
                              child: GestureDetector(
                                onTap: _addToBench,
                                child: Container(
                                  width: 130,
                                  height: 200,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.white24),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.add,
                                      color: Colors.white24,
                                      size: 40,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }
                        }),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
