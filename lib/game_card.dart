import 'package:flutter/material.dart';
import 'package:dev_cards/const.dart';

class GameCard {
  final String id;
  final String name;
  final int power;
  final CardElement element;
  final String description;
  final String iconRef;
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
      case 'code':
        return Icons.code;
      case 'fire':
        return Icons.local_fire_department;
      case 'wifi':
        return Icons.wifi;
      case 'security':
        return Icons.security;
      case 'branch':
        return Icons.call_split;
      case 'link':
        return Icons.link;
      case 'plane':
        return Icons.flight;
      case 'snow':
        return Icons.ac_unit;
      case 'delete':
        return Icons.delete;
      case 'error':
        return Icons.error;
      case 'desktop':
        return Icons.desktop_windows;
      case 'science':
        return Icons.science;
      case 'database':
        return Icons.storage;
      case 'brain':
        return Icons.psychology;
      case 'mask':
        return Icons.privacy_tip;
      case 'cookie':
        return Icons.donut_small;
      case 'moon':
        return Icons.dark_mode;
      case 'keyboard':
        return Icons.keyboard;
      case 'key':
        return Icons.vpn_key;
      case 'layers':
        return Icons.layers;
      case 'loop':
        return Icons.loop;
      case 'target':
        return Icons.gps_fixed;
      case 'grid':
        return Icons.grid_on;
      case 'water':
        return Icons.water_drop;
      case 'satellite':
        return Icons.satellite_alt;
      case 'skull':
        return Icons.dangerous;
      case 'mouse':
        return Icons.mouse;
      case 'duck':
        return Icons.pets;
      case 'hook':
        return Icons.phishing;
      case 'sun':
        return Icons.wb_sunny;
      case 'fan':
        return Icons.wind_power;
      case 'server':
        return Icons.dns;
      case 'chip':
        return Icons.memory;
      case 'lock':
        return Icons.lock;
      case 'bluetooth':
        return Icons.bluetooth;
      case 'money':
        return Icons.attach_money;
      case 'heart':
        return Icons.favorite;
      case 'dino':
        return Icons.warning;
      case 'terminal':
        return Icons.terminal;
      case 'box':
        return Icons.inbox;
      case 'robot':
        return Icons.smart_toy;
      case 'atom':
        return Icons.science;
      case 'pickaxe':
        return Icons.construction;
      case 'save':
        return Icons.save;
      case 'cloud_rain':
        return Icons.cloud_download;
      case 'mail':
        return Icons.mail;
      case 'run':
        return Icons.directions_run;
      case 'anchor':
        return Icons.anchor;
      case 'cassette':
        return Icons.radio;
      case 'battery':
        return Icons.battery_charging_full;
      case 'ping':
        return Icons.network_ping;
      case 'split':
        return Icons.call_split;
      case 'cable':
        return Icons.cable;
      case 'drop':
        return Icons.water_drop;
      case 'bomb':
        return Icons.dangerous;
      case 'hat':
        return Icons.school;
      case 'hand':
        return Icons.waving_hand;
      default:
        return Icons.style;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'power': power,
      'element': element.name,
      'description': description,
      'icon_ref': iconRef,
    };
  }
}
