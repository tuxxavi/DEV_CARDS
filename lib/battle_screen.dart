// ignore_for_file: deprecated_member_use, avoid_print, use_build_context_synchronously

import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:dev_cards/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:dev_cards/const.dart';
import 'package:dev_cards/destructible_widget.dart';
import 'package:dev_cards/game_card.dart';
import 'package:dev_cards/game_manager.dart';
import 'package:dev_cards/mini_card_back.dart';
import 'package:dev_cards/pack_opening_screen.dart';
import 'package:dev_cards/particle_explosion_layer.dart';
import 'package:dev_cards/pokemon_style_card.dart';
import 'package:dev_cards/server_manager.dart';
import 'package:dev_cards/stadium_background.dart';

class BattleScreen extends StatefulWidget {
  final List<GameCard> playerStartingCards;
  final bool isOnline;
  const BattleScreen({
    super.key,
    required this.playerStartingCards,
    this.isOnline = false,
  });
  @override
  State<BattleScreen> createState() => _BattleScreenState();
}

class _BattleScreenState extends State<BattleScreen>
    with TickerProviderStateMixin {
  List<GameCard> deck = [],
      playerHand = [],
      initialPlayerHand = [],
      cpuHand = [];
  GameCard? playerActiveCard, cpuActiveCard;
  int playerScore = 0, cpuScore = 0;
  String battleLog = "";
  bool isProcessingTurn = false;

  StreamSubscription? _serverSub;
  Timer? _turnTimer;
  int _timeLeft = 5;
  bool _opponentHasPicked = false;
  GameCard? _pendingOpponentCard;

  late AnimationController _clashShakeController;
  late Animation<double> _shakeAnim;
  String? _destroyedCardInstanceId;
  Color _arenaFlashColor = Colors.transparent;
  final GlobalKey _arenaKey = GlobalKey();

  final StreamController<Offset> _clashExplosionCtrl =
      StreamController<Offset>.broadcast();

  @override
  void initState() {
    super.initState();
    _clashShakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _shakeAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 10.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 10.0, end: -10.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -10.0, end: 10.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 10.0, end: 0.0), weight: 1),
    ]).animate(_clashShakeController);

    Future.delayed(Duration.zero, () {
      _startNewGame();
      if (widget.isOnline) {
        _serverSub = ServerManager.onData.listen(_handleOnlineMessage);
        _startOnlineRound();
      }
    });
  }

  void _startOnlineRound() {
    setState(() {
      _timeLeft = 5;
      _opponentHasPicked = false;
      _pendingOpponentCard = null;
      battleLog = "${AppLocalizations.of(context)!.pick_card} ($_timeLeft s)";
      isProcessingTurn = false;
      playerActiveCard = null;
      cpuActiveCard = null;
    });

    _turnTimer?.cancel();
    _turnTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        _timeLeft--;
        if (playerActiveCard == null) {
          battleLog =
              "${AppLocalizations.of(context)!.pick_card} ($_timeLeft s)";
        }
      });
      if (_timeLeft <= 0) {
        timer.cancel();
        if (playerActiveCard == null && playerHand.isNotEmpty) {
          _playTurn(playerHand[0]);
        }
      }
    });
  }

  void _handleOnlineMessage(String msg) {
    try {
      final Map<String, dynamic> data = jsonDecode(msg);
      if (data['type'] == 'PICK') {
        final card = GameCard.fromJson(data['card']);
        setState(() {
          _opponentHasPicked = true;
          _pendingOpponentCard = card;
        });
        _checkOnlineResolution();
      }
    } catch (e) {
      print("Error parsing online msg: $e");
    }
  }

  void _checkOnlineResolution() async {
    if (playerActiveCard != null && _opponentHasPicked) {
      _turnTimer?.cancel();
      await Future.delayed(const Duration(milliseconds: 500));
      setState(() {
        cpuActiveCard = _pendingOpponentCard;

        if (cpuHand.isNotEmpty) cpuHand.removeAt(0);
      });
      _resolveRound();
    } else if (playerActiveCard != null) {
      setState(
        () => battleLog = AppLocalizations.of(context)!.waiting_opponent,
      );
    }
  }

  @override
  void dispose() {
    _clashShakeController.dispose();
    _clashExplosionCtrl.close();
    _serverSub?.cancel();
    _turnTimer?.cancel();
    super.dispose();
  }

  void _startNewGame() {
    List<GameCard> tempDeck = List.from(GameManager.allCardsMaster);
    tempDeck.shuffle();

    if (tempDeck.length < 6) tempDeck.addAll(tempDeck);

    setState(() {
      deck = tempDeck;
      playerHand = List.from(widget.playerStartingCards);
      initialPlayerHand = List.from(playerHand);
      cpuHand = deck.take(3).toList();

      playerActiveCard = null;
      cpuActiveCard = null;
      playerScore = 0;
      cpuScore = 0;
      battleLog = AppLocalizations.of(context)!.your_turn;
      isProcessingTurn = false;
      _destroyedCardInstanceId = null;
      _arenaFlashColor = Colors.transparent;
    });
  }

  void _playTurn(GameCard playerCard) async {
    if (isProcessingTurn && !widget.isOnline) return;
    if (playerActiveCard != null) return;

    setState(() {
      isProcessingTurn = true;
      playerHand.remove(playerCard);
      playerActiveCard = playerCard;
    });

    if (widget.isOnline) {
      ServerManager.send(
        jsonEncode({"type": "PICK", "card": playerCard.toJson()}),
      );
      _checkOnlineResolution();
    } else {
      setState(
        () => battleLog =
            "${AppLocalizations.of(context)!.summoning} ${playerCard.name}...",
      );
      await Future.delayed(const Duration(milliseconds: 600));
      final random = Random();
      if (cpuHand.isEmpty) {
        _endGameSequence();
        return;
      }
      final cpuCard = cpuHand[random.nextInt(cpuHand.length)];
      setState(() {
        cpuHand.remove(cpuCard);
        cpuActiveCard = cpuCard;
      });
      await Future.delayed(const Duration(milliseconds: 600));
      _resolveRound();
    }
  }

  void _resolveRound() async {
    _clashShakeController.forward(from: 0);

    if (_arenaKey.currentContext != null) {
      RenderBox box = _arenaKey.currentContext!.findRenderObject() as RenderBox;
      Offset center = box.localToGlobal(box.size.center(Offset.zero));
      _clashExplosionCtrl.add(center);
    }

    await Future.delayed(const Duration(milliseconds: 300));

    int pPower = playerActiveCard!.power;
    int cPower = cpuActiveCard!.power;
    bool bonus =
        (playerActiveCard!.element == CardElement.fire &&
            cpuActiveCard!.element == CardElement.earth) ||
        (playerActiveCard!.element == CardElement.water &&
            cpuActiveCard!.element == CardElement.fire);
    if (bonus) pPower += 30;

    String resultLog;
    Color flashColor;
    String? loserId;

    if (pPower > cPower) {
      playerScore++;
      resultLog =
          "${AppLocalizations.of(context)!.won_round} ${bonus ? '(${AppLocalizations.of(context)!.bonus})' : ''}";
      flashColor = Colors.green.withOpacity(0.5);
      loserId = cpuActiveCard!.instanceId;
    } else if (cPower > pPower) {
      cpuScore++;
      resultLog = AppLocalizations.of(context)!.lost_round;
      flashColor = Colors.red.withOpacity(0.5);
      loserId = playerActiveCard!.instanceId;
    } else {
      resultLog = AppLocalizations.of(context)!.draw;
      flashColor = Colors.blue.withOpacity(0.3);
    }

    setState(() {
      battleLog = resultLog;
      _arenaFlashColor = flashColor;
      _destroyedCardInstanceId = loserId;
    });

    await Future.delayed(const Duration(milliseconds: 1200));

    setState(() {
      _arenaFlashColor = Colors.transparent;
    });

    if (playerHand.isEmpty) {
      _endGameSequence();
    } else {
      setState(() {
        playerActiveCard = null;
        cpuActiveCard = null;
        isProcessingTurn = false;
        _destroyedCardInstanceId = null;
      });
      if (widget.isOnline) {
        _startOnlineRound();
      }
    }
  }

  void _endGameSequence() {
    bool isVictory = playerScore > cpuScore;
    if (isVictory) GameManager.addToAlbum(initialPlayerHand);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) =>
            PackOpeningScreen(isVictory: isVictory, isOnline: widget.isOnline),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Ignoramos isLandscape para forzar diseño vertical (mobile-style)
    return PopScope(
      canPop: false,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: _arenaFlashColor == Colors.transparent
                  ? Colors.black54
                  : _arenaFlashColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white24),
            ),
            child: Text(
              "$playerScore - $cpuScore",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false,
          actions: [],
        ),
        body: Stack(
          children: [
            const Positioned.fill(child: StadiumBackground(animate: true)),
            Positioned.fill(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeOut,
                color: _arenaFlashColor,
              ),
            ),
            ParticleExplosionLayer(triggerStream: _clashExplosionCtrl.stream),

            Positioned.fill(
              child: DragTarget<GameCard>(
                builder: (context, candidateData, rejectedData) {
                  return Container(color: Colors.transparent);
                },
                onWillAccept: (data) =>
                    !isProcessingTurn && playerActiveCard == null,
                onAccept: (data) => _playTurn(data),
              ),
            ),

            SafeArea(child: _buildPortraitLayout()),
            Positioned.fill(child: IgnorePointer(child: _buildArenaVisuals())),
          ],
        ),
      ),
    );
  }

  Widget _buildPortraitLayout() {
    return Column(
      children: [
        const SizedBox(height: 10),
        _buildHandList(cpuHand, false, true),
        const Spacer(),
        Align(
          alignment: Alignment.bottomCenter,
          child: _buildHandList(playerHand, true, true),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildArenaVisuals() {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth * 0.4;

    return Container(
      key: _arenaKey,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (cpuActiveCard != null)
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 20.0),
                child: AnimatedBuilder(
                  animation: _shakeAnim,
                  builder: (ctx, child) => Transform.translate(
                    offset: Offset(_shakeAnim.value, 0),
                    child: child,
                  ),
                  child: SizedBox(
                    width: cardWidth,
                    child: FittedBox(
                      fit: BoxFit.contain,
                      child: DestructibleWidget(
                        isDestroyed:
                            cpuActiveCard!.instanceId ==
                            _destroyedCardInstanceId,
                        child: PokemonStyleCard(card: cpuActiveCard!),
                      ),
                    ),
                  ),
                ),
              ),
            ),

          if (playerActiveCard != null)
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 20.0),
                child: AnimatedBuilder(
                  animation: _shakeAnim,
                  builder: (ctx, child) => Transform.translate(
                    offset: Offset(_shakeAnim.value, 0),
                    child: child,
                  ),
                  child: SizedBox(
                    width: cardWidth,
                    child: FittedBox(
                      fit: BoxFit.contain,
                      child: DestructibleWidget(
                        isDestroyed:
                            playerActiveCard!.instanceId ==
                            _destroyedCardInstanceId,
                        child: PokemonStyleCard(card: playerActiveCard!),
                      ),
                    ),
                  ),
                ),
              ),
            ),

          Positioned(
            bottom: 0,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, anim) => FadeTransition(
                opacity: anim,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.0, -0.5),
                    end: Offset.zero,
                  ).animate(anim),
                  child: child,
                ),
              ),
              child: Text(
                battleLog,
                key: ValueKey(battleLog),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [Shadow(color: Colors.black, blurRadius: 10)],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHandList(List<GameCard> hand, bool isPlayer, bool isHorizontal) {
    double screenWidth = MediaQuery.of(context).size.width;

    double cardWidth = isHorizontal ? (screenWidth - 32) / 3 : 130;

    return SizedBox(
      height: isHorizontal ? 220 : null,
      width: isHorizontal ? null : 130,
      child: Center(
        child: ListView.builder(
          scrollDirection: isHorizontal ? Axis.horizontal : Axis.vertical,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          itemCount: hand.length,
          shrinkWrap: true,
          physics: const ClampingScrollPhysics(),
          itemBuilder: (ctx, i) {
            final cardWidget = isPlayer
                ? Draggable<GameCard>(
                    data: hand[i],
                    feedback: Material(
                      color: Colors.transparent,
                      child: Transform.scale(
                        scale: 1.1,
                        child: PokemonStyleCard(card: hand[i], isSmall: true),
                      ),
                    ),
                    childWhenDragging: Opacity(
                      opacity: 0.5,
                      child: Transform.scale(
                        scale: 0.75,
                        child: PokemonStyleCard(card: hand[i], isSmall: true),
                      ),
                    ),
                    child: GestureDetector(
                      onTap: () => _playTurn(hand[i]),
                      child: PokemonStyleCard(card: hand[i], isSmall: true),
                    ),
                  )
                : const MiniCardBack(width: 130, height: 200);

            // Wrap in a container constrained by screen width
            return Container(
              width: cardWidth,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: FittedBox(fit: BoxFit.contain, child: cardWidget),
            );
          },
        ),
      ),
    );
  }
}
