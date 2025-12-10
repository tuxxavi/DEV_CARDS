import 'dart:math';

import 'package:flutter/material.dart';
import 'package:dev_cards/game_card.dart';
import 'package:dev_cards/mini_card_back.dart';
import 'package:dev_cards/pokemon_style_card.dart';

class CardDetail3DDialog extends StatefulWidget {
  final GameCard card;
  const CardDetail3DDialog({super.key, required this.card});
  @override
  State<CardDetail3DDialog> createState() => _CardDetail3DDialogState();
}

class _CardDetail3DDialogState extends State<CardDetail3DDialog> {
  double _rotX = 0;
  double _rotY = 0;

  @override
  Widget build(BuildContext context) {
    double y = _rotY % (2 * pi);
    if (y < 0) y += 2 * pi;
    bool isBack = y > pi / 2 && y < 3 * pi / 2;

    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      onPanUpdate: (details) {
        setState(() {
          _rotY -= details.delta.dx * 0.01;
          _rotX += details.delta.dy * 0.01;
          _rotX = _rotX.clamp(-0.4, 0.4);
        });
      },
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.black54,
          alignment: Alignment.center,
          child: Transform(
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateX(_rotX)
              ..rotateY(_rotY),
            alignment: Alignment.center,
            child: Transform.scale(
              scale: 1.5,
              child: isBack
                  ? Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.rotationY(pi),
                      child: const MiniCardBack(width: 150, height: 230),
                    )
                  : PokemonStyleCard(card: widget.card),
            ),
          ),
        ),
      ),
    );
  }
}
