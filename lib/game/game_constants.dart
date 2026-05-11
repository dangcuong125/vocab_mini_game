import 'package:flutter/material.dart';

class GameConstants {
  GameConstants._();

  // Spawn
  static const double spawnInterval = 2.5;
  static const int maxActiveWords = 3;
  static const double spawnInitialY = -50.0;
  static const double spawnMarginX = 75.0;

  // Gun
  static const double gunOffsetFromBottom = 8.0;
  static const double gunWidth = 60.0;
  static const double gunHeight = 60.0;
  static const double gunBodyRadius = 26.0;
  static const double gunBarrelOffsetY = 22.0;
  static const double gunBarrelWidth = 13.0;
  static const double gunBarrelHeight = 26.0;
  static const double gunBarrelRadius = 4.0;
  static const double gunHighlightOffsetX = 6.0;
  static const double gunHighlightOffsetY = 6.0;
  static const double gunHighlightRadius = 8.0;
  static const double gunBulletStartOffset = 32.0;
  static const Color gunBodyColor = Color(0xFF546E7A);
  static const Color gunBarrelColor = Color(0xFF263238);

  // Bullet
  static const double bulletSpeed = 600.0;
  static const double bulletWidth = 8.0;
  static const double bulletHeight = 16.0;
  static const double bulletRadius = 4.0;
  static const double bulletOffscreenThreshold = -20.0;
  static const Color bulletColor = Colors.yellowAccent;

  // Falling word
  static const double wordSpeed = 60.0;
  static const double wordWidth = 130.0;
  static const double wordHeight = 46.0;
  static const double wordBorderRadius = 10.0;
  static const double wordFontSize = 16.0;
  static const int wordWrongFlashMs = 350;
  static const Color wordNormalColor = Color(0xFF1565C0);
  static const Color wordWrongColor = Color(0xFFD32F2F);
  static const Color wordTextColor = Colors.white;

  // Limit line
  static const double limitLineAboveGun = 20.0;
  static const double limitLineStrokeWidth = 1.5;
  static const Color limitLineColor = Color.fromARGB(255, 84, 185, 194);
  static const double limitLineAlpha = 0.75;

  // Game background
  static const Color gameBackgroundColor = Color.fromARGB(255, 81, 154, 232);
}
