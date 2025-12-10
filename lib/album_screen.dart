import 'package:dev_cards/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:dev_cards/card_detail3_d_dialog.dart';
import 'package:dev_cards/game_manager.dart';
import 'package:dev_cards/pokemon_style_card.dart';

class AlbumScreen extends StatelessWidget {
  const AlbumScreen({super.key});
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    int cols = (width / 160).floor();
    if (cols < 2) cols = 2;
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.my_collection),
        backgroundColor: Colors.transparent,
      ),
      body: GameManager.userAlbum.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.sentiment_dissatisfied,
                    size: 60,
                    color: Colors.grey[800],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    AppLocalizations.of(context)!.no_cards_yet,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: cols,
                childAspectRatio: 0.7,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: GameManager.userAlbum.length,
              itemBuilder: (context, index) {
                // Animación de entrada escalonada
                return TweenAnimationBuilder(
                  duration: Duration(
                    milliseconds: 300 + (index * 50).clamp(0, 1000),
                  ),
                  tween: Tween<double>(begin: 0, end: 1),
                  curve: Curves.easeOutBack,
                  builder: (context, value, child) =>
                      Transform.scale(scale: value, child: child),
                  child: GestureDetector(
                    onTap: () => showDialog(
                      context: context,
                      builder: (_) => CardDetail3DDialog(
                        card: GameManager.userAlbum[index],
                      ),
                    ),
                    child: PokemonStyleCard(
                      card: GameManager.userAlbum[index],
                      isSmall: true,
                    ),
                  ),
                );
              },
            ),
    );
  }
}
