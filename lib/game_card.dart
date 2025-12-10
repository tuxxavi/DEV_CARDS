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
        return Icons.flash_on; // Also for Thunderbolt, Laser
      case 'shield':
        return Icons.security; // Also for Rust Armor, Typescript
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
        return Icons.call_split; // Git Merge
      case 'link':
        return Icons.link; // Blockchain
      case 'plane':
        return Icons.flight;
      case 'snow':
        return Icons.ac_unit; // Penguin
      case 'delete':
        return Icons.delete;
      case 'error':
        return Icons.error;
      case 'desktop': // Blue Screen
        return Icons.desktop_windows;
      case 'science':
        return Icons.science; // React Atom
      case 'database':
        return Icons.storage; // SQL
      case 'brain':
        return Icons.psychology; // Neural Net
      case 'mask':
        return Icons.privacy_tip; // Incognito, Hacker
      case 'cookie':
        return Icons.donut_small; // Cookie (approx)
      case 'moon':
        return Icons.dark_mode;
      case 'keyboard':
        return Icons.keyboard;
      case 'key':
        return Icons.vpn_key;
      case 'layers':
        return Icons.layers; // Stack Overflow
      case 'loop': // Infinite Loop
        return Icons.loop;
      case 'target': // Sniper
        return Icons.gps_fixed;
      case 'grid': // Pixel Art, CSS Grid
        return Icons.grid_on;
      case 'water': // Liquid Cooling
        return Icons.water_drop;
      case 'satellite':
        return Icons.satellite_alt;
      case 'skull': // Virus
        return Icons.dangerous;
      case 'mouse': // Pointer
        return Icons.mouse;
      case 'duck':
        return Icons.pets; // Rubber Duck
      case 'hook':
        return Icons.phishing; // Phishing
      case 'sun':
        return Icons.wb_sunny;
      case 'fan':
        return Icons.wind_power; // Turbine
      case 'server':
        return Icons.dns; // Mainframe
      case 'chip':
        return Icons.memory;
      case 'lock':
        return Icons.lock; // VPN
      case 'bluetooth':
        return Icons.bluetooth;
      case 'money':
        return Icons.attach_money; // Ransomware
      case 'heart':
        return Icons.favorite; // Open Source
      case 'dino':
        return Icons.warning; // T-Rex
      case 'terminal': // CLI, Sudo
        return Icons.terminal;
      case 'box': // Zip Bomb, Sandbox
        return Icons.inbox;
      case 'robot': // Captcha
        return Icons.smart_toy;
      case 'atom': // Quantum Bit
        return Icons.science;
      case 'pickaxe': // Mining
        return Icons.construction;
      case 'save': // Floppy
        return Icons.save;
      case 'cloud_rain': // Leaking
        return Icons.cloud_download;
      case 'mail': // Spam
        return Icons.mail;
      case 'run': // Agile
        return Icons.directions_run;
      case 'anchor': // Deep Web
        return Icons.anchor;
      case 'cassette': // Backup Tape
        return Icons.radio;
      case 'battery': // Wireless Charge
        return Icons.battery_charging_full;
      case 'ping': // Ping Pong
        return Icons.network_ping;
      case 'split': // Fork
        return Icons.call_split;
      case 'cable': // Fiber
        return Icons.cable;
      case 'drop': // Leak
        return Icons.water_drop;
      case 'bomb': // Zero Day
        return Icons.dangerous;
      case 'hat': // White Hat
        return Icons.school;
      case 'hand': // Hello World
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
      'element': element.name, // Enum to string
      'description': description,
      'icon_ref': iconRef,
    };
  }
}
