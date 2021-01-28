import 'package:flutter/material.dart';

class VideoControllerTheme {
  final Color progressColor;
  final Color bufferedProgressColor;
  final Color backgroundProgressColor;
  final Color iconColor;
  final TextStyle durationStyle;
  final Color backgroundPlayer;

  const VideoControllerTheme({
    this.progressColor = const Color(0xFF22A3D2),
    this.bufferedProgressColor = const Color(0x5583D8F7),
    this.backgroundProgressColor = const Color(0x5515162B),
    this.iconColor = const Color(0x0FFFFFFFF),
    this.durationStyle = const TextStyle(
      color: Color(0x0FFFFFFFF),
    ),
    this.backgroundPlayer = const Color(0x662F2C47),
  });
}
