import 'package:flutter/material.dart';
import 'package:dev_cards/const.dart';

class GameCard {
  final String id;
  final String name;
  final int power;
  final CardElement element;
  final String description;
  final String iconRef;
  // ID único para instancias en juego (para animaciones de destrucción)
  String instanceId = UniqueKey().toString();

  GameCard({
    required this.id,
    required this.name,
    required this.power,
    required this.element,
    required this.description,
    required this.iconRef,
  });

  factory GameCard.fromJson(Map<String, dynamic> json) {
    return GameCard(
      id: json['id'],
      name: json['name'],
      power: json['power'],
      element: _parseElement(json['element']),
      description: json['description'],
      iconRef: json['icon_ref'],
    );
  }
  static CardElement _parseElement(String elem) {
    switch (elem.toLowerCase()) {
      case 'fire':
        return CardElement.fire;
      case 'water':
        return CardElement.water;
      case 'air':
        return CardElement.air;
      case 'earth':
        return CardElement.earth;
      default:
        return CardElement.air;
    }
  }

  Color get color {
    switch (element) {
      case CardElement.fire:
        return const Color(0xFFEA4335);
      case CardElement.water:
        return const Color(0xFF4285F4);
      case CardElement.air:
        return const Color(0xFFFBBC04);
      case CardElement.earth:
        return const Color(0xFF34A853);
    }
  }

  IconData get mainIcon {
    switch (iconRef) {
      case 'dash':
        return Icons.flutter_dash;
      case 'bug':
        return Icons.bug_report;
      case 'stream':
        return Icons.waves;
      case 'rock':
        return Icons.landscape;
      case 'cloud':
        return Icons.cloud_queue;
      case 'flash':
        return Icons.flash_on;
      case 'shield':
        return Icons.security;
      case 'noodle':
        return Icons.gesture;
      default:
        return Icons.help_outline;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'power': power,
      'element': element.name, // Enum to string
      'description': description,
      'icon_ref': iconRef,
    };
  }
}
