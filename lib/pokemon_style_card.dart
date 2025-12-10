// ignore_for_file: deprecated_member_use
import 'package:dev_cards/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:dev_cards/const.dart';
import 'package:dev_cards/game_card.dart';

class PokemonStyleCard extends StatelessWidget {
  final GameCard card;
  final bool isSmall;
  const PokemonStyleCard({super.key, required this.card, this.isSmall = false});
  @override
  Widget build(BuildContext context) {
    double w = isSmall ? 130 : 150;
    double h = isSmall ? 200 : 230;
    double iconSize = isSmall ? 40 : 50;
    double fontSizePower = isSmall ? 16 : 18;
    return Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        color: const Color(0xFF151515),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: card.color, width: 3),
        boxShadow: [
          BoxShadow(
            color: card.color.withOpacity(0.5),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 28,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: card.color.withOpacity(0.3),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    card.id,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 8,
                      color: Colors.white,
                    ),
                  ),
                ),
                Flexible(
                  child: Text(
                    card.name,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                      color: Colors.white,
                    ),
                  ),
                ),
                Icon(
                  card.element == CardElement.fire
                      ? Icons.whatshot
                      : card.element == CardElement.water
                      ? Icons.water_drop
                      : card.element == CardElement.air
                      ? Icons.air
                      : Icons.terrain,
                  size: 12,
                  color: card.color,
                ),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Container(
              margin: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.grey[900]!, card.color.withOpacity(0.5)],
                ),
                border: Border.all(color: Colors.white24),
              ),
              child: Center(
                child: Icon(card.mainIcon, size: iconSize, color: Colors.white),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Center(
                child: Text(
                  card.description,
                  style: const TextStyle(
                    fontSize: 9,
                    color: Colors.white70,
                    fontStyle: FontStyle.italic,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          Container(
            height: 35,
            decoration: BoxDecoration(
              color: card.color,
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(12),
              ),
            ),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    AppLocalizations.of(context)!.power,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    "${card.power}",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: fontSizePower,
                      fontWeight: FontWeight.w900,
                    ),
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
