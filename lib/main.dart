import 'package:flame/game.dart';
import 'package:flameflutter/overlays/game_over.dart';
import 'package:flameflutter/overlays/main_menu.dart';
import 'package:flutter/material.dart';

import 'mario_quest.dart';

void main() {
  runApp(
    GameWidget<marioQuestGame>.controlled(
      gameFactory: marioQuestGame.new,
      overlayBuilderMap: {
        'MainMenu': (_, game) => MainMenu(game: game),
        'GameOver': (_, game) => GameOver(game: game),
      },
      initialActiveOverlays: const ['MainMenu'],
    ),
  );
}
