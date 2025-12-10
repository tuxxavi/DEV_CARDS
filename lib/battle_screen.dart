// ignore_for_file: deprecated_member_use, avoid_print

import 'dart:async';
import 'dart:convert';
import 'dart:math';

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
  String battleLog = "Iniciando...";
  bool isProcessingTurn = false;

  // Online vars
  StreamSubscription? _serverSub;
  Timer? _turnTimer;
  int _timeLeft = 5;
  bool _opponentHasPicked = false;
  GameCard? _pendingOpponentCard;

  // Controladores de Animación
  late AnimationController _clashShakeController;
  late Animation<double> _shakeAnim;
  String? _destroyedCardInstanceId; // Para saber qué carta destruir visualmente
  Color _arenaFlashColor = Colors.transparent; // Color de feedback del estadio
  final GlobalKey _arenaKey = GlobalKey(); // Para posicionar partículas

  // Controladores de partículas
  final StreamController<Offset> _clashExplosionCtrl =
      StreamController<Offset>.broadcast();

  @override
  void initState() {
    super.initState();
    _clashShakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    // Un shake rápido de izquierda a derecha
    _shakeAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 10.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 10.0, end: -10.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -10.0, end: 10.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 10.0, end: 0.0), weight: 1),
    ]).animate(_clashShakeController);

    _startNewGame();
    if (widget.isOnline) {
      _serverSub = ServerManager.onData.listen(_handleOnlineMessage);
      _startOnlineRound();
    }
  }

  void _startOnlineRound() {
    setState(() {
      _timeLeft = 5;
      _opponentHasPicked = false;
      _pendingOpponentCard = null;
      battleLog = "¡Escoge carta! ($_timeLeft s)";
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
          battleLog = "¡Escoge carta! ($_timeLeft s)";
        }
      });
      if (_timeLeft <= 0) {
        timer.cancel();
        if (playerActiveCard == null && playerHand.isNotEmpty) {
          _playTurn(playerHand[0]); // Auto-pick
        }
      }
    });
  }

  void _handleOnlineMessage(String msg) {
    // msg: {"type":"PICK", "card": {...}}
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
    // Si ya escogí y el oponente también
    if (playerActiveCard != null && _opponentHasPicked) {
      _turnTimer?.cancel();
      await Future.delayed(const Duration(milliseconds: 500));
      setState(() {
        // Revelar carta oponente
        cpuActiveCard = _pendingOpponentCard;
        // Remove fake card from visual hand if we were tracking it,
        // but strictly we just show deck size.
        if (cpuHand.isNotEmpty) cpuHand.removeAt(0);
      });
      _resolveRound();
    } else if (playerActiveCard != null) {
      setState(() => battleLog = "Esperando al oponente...");
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
    // Asegurar que CPU tenga cartas
    if (tempDeck.length < 6) tempDeck.addAll(tempDeck);

    setState(() {
      deck = tempDeck;
      playerHand = List.from(
        widget.playerStartingCards,
      ); // Usar las cartas seleccionadas
      initialPlayerHand = List.from(playerHand);
      cpuHand = deck.take(3).toList(); // CPU toma del mazo aleatorio

      playerActiveCard = null;
      cpuActiveCard = null;
      playerScore = 0;
      cpuScore = 0;
      battleLog = "¡TU TURNO!";
      isProcessingTurn = false;
      _destroyedCardInstanceId = null;
      _arenaFlashColor = Colors.transparent;
    });
  }

  void _playTurn(GameCard playerCard) async {
    if (isProcessingTurn && !widget.isOnline) return;
    if (playerActiveCard != null) return; // Already picked

    setState(() {
      isProcessingTurn = true; // Block input
      playerHand.remove(playerCard);
      playerActiveCard = playerCard;
    });

    if (widget.isOnline) {
      // Send pick
      ServerManager.send(
        jsonEncode({"type": "PICK", "card": playerCard.toJson()}),
      );
      _checkOnlineResolution();
    } else {
      // Offline Logic
      setState(() => battleLog = "Invocando ${playerCard.name}...");
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
    // 1. Animación de Choque (Shake + Partículas)
    _clashShakeController.forward(from: 0);
    // Trigger partículas en el centro de la arena
    if (_arenaKey.currentContext != null) {
      RenderBox box = _arenaKey.currentContext!.findRenderObject() as RenderBox;
      Offset center = box.localToGlobal(box.size.center(Offset.zero));
      _clashExplosionCtrl.add(center); // ¡BOOM!
    }

    await Future.delayed(const Duration(milliseconds: 300)); // Esperar shake

    int pPower = playerActiveCard!.power;
    int cPower = cpuActiveCard!.power;
    bool bonus =
        (playerActiveCard!.element == CardElement.fire &&
            cpuActiveCard!.element == CardElement.earth) ||
        (playerActiveCard!.element == CardElement.water &&
            cpuActiveCard!.element == CardElement.fire); // Ejemplo simplificado
    if (bonus) pPower += 30;

    String resultLog;
    Color flashColor;
    String? loserId;

    if (pPower > cPower) {
      playerScore++;
      resultLog = "¡GANASTE LA RONDA! ${bonus ? '(Bonus)' : ''}";
      flashColor = Colors.green.withOpacity(0.5);
      loserId = cpuActiveCard!.instanceId;
    } else if (cPower > pPower) {
      cpuScore++;
      resultLog = "RONDA PERDIDA...";
      flashColor = Colors.red.withOpacity(0.5);
      loserId = playerActiveCard!.instanceId;
    } else {
      resultLog = "EMPATE";
      flashColor = Colors.blue.withOpacity(0.3);
    }

    setState(() {
      battleLog = resultLog;
      _arenaFlashColor = flashColor;
      _destroyedCardInstanceId = loserId; // Marcar para destrucción
    });

    // 2. Esperar animación de destrucción y feedback
    await Future.delayed(const Duration(milliseconds: 1200));

    setState(() {
      _arenaFlashColor = Colors.transparent;
    }); // Limpiar flash

    if (playerHand.isEmpty) {
      _endGameSequence();
    } else {
      setState(() {
        // Reset Round
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
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    return Scaffold(
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
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: Stack(
        children: [
          const Positioned.fill(child: StadiumBackground(animate: true)),
          // Capa de flash para el estadio
          Positioned.fill(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOut,
              color: _arenaFlashColor,
            ),
          ),
          // Emisor de partículas de choque
          ParticleExplosionLayer(triggerStream: _clashExplosionCtrl.stream),

          // CAPA 1: Drag Target (Fondo interactivo)
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

          // CAPA 2: Manos (UI)
          SafeArea(
            child: isLandscape
                ? _buildLandscapeLayout()
                : _buildPortraitLayout(),
          ),

          // CAPA 3: Visuales de la Arena (Sobre todo lo demás)
          Positioned.fill(child: IgnorePointer(child: _buildArenaVisuals())),
        ],
      ),
    );
  }

  Widget _buildPortraitLayout() {
    return Column(
      children: [
        const SizedBox(height: 10),
        // CPU Hand (Top)
        _buildHandList(cpuHand, false, true),
        const Spacer(),
        // Player Hand (Bottom)
        Align(
          alignment: Alignment.bottomCenter,
          child: _buildHandList(playerHand, true, true),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildLandscapeLayout() {
    return Row(
      children: [
        _buildHandList(playerHand, true, false),
        const Spacer(),
        _buildHandList(cpuHand, false, false),
      ],
    );
  }

  Widget _buildArenaVisuals() {
    return Container(
      key: _arenaKey, // Key para encontrar el centro
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 100, // Ajustado para que no tape el marcador
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

          // CPU a la IZQUIERDA
          if (cpuActiveCard != null)
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 30),
                child: AnimatedBuilder(
                  animation: _shakeAnim,
                  builder: (ctx, child) => Transform.translate(
                    offset: Offset(_shakeAnim.value, 0),
                    child: child,
                  ),
                  child: DestructibleWidget(
                    isDestroyed:
                        cpuActiveCard!.instanceId == _destroyedCardInstanceId,
                    child: Transform.scale(
                      scale: 1.2, // Cartas grandes en el choque
                      child: PokemonStyleCard(card: cpuActiveCard!),
                    ),
                  ),
                ),
              ),
            ),

          // Jugador a la DERECHA
          if (playerActiveCard != null)
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 30),
                child: AnimatedBuilder(
                  animation: _shakeAnim,
                  builder: (ctx, child) => Transform.translate(
                    offset: Offset(_shakeAnim.value, 0),
                    child: child,
                  ),
                  child: DestructibleWidget(
                    isDestroyed:
                        playerActiveCard!.instanceId ==
                        _destroyedCardInstanceId,
                    child: Transform.scale(
                      scale: 1.2, // Cartas grandes en el choque
                      child: PokemonStyleCard(card: playerActiveCard!),
                    ),
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
    // Calcular ancho para que caban 3 cartas con un poco de margen
    // Si es landscape/vertical list, usamos ancho fijo.
    double cardWidth = isHorizontal ? (screenWidth - 32) / 3 : 130;

    return SizedBox(
      height: isHorizontal
          ? 220
          : null, // Aumentamos altura para permitir growth
      width: isHorizontal ? null : 130,
      child: Center(
        // Centrar si hay menos cartas (opcional, pero ListView no centra por defecto)
        child: ListView.builder(
          scrollDirection: isHorizontal ? Axis.horizontal : Axis.vertical,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          itemCount: hand.length,
          shrinkWrap: true, // Para que el Center funcione si hay pocas cartas
          physics:
              const ClampingScrollPhysics(), // Evitar scroll innecesario si caben
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
                        scale: 0.75, // Mantener escala visual pequeña en drag
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
