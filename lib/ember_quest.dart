import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flameflutter/actors/mushroom_enemy.dart';
import 'package:flameflutter/managers/segment_manager.dart';
import 'package:flameflutter/objects/ground_block.dart';
import 'package:flameflutter/objects/platform_block.dart';
import 'package:flameflutter/objects/star.dart';
import 'package:flameflutter/overlays/hud.dart';
import 'package:flutter/material.dart';

import 'actors/ember.dart';

class EmberQuestGame extends FlameGame
    with HasCollisionDetection, HasKeyboardHandlerComponents {
  EmberQuestGame();

  late EmberPlayer _ember;
  double objectSpeed = 0.0;
  late double lastBlockXPosition = 0.0;
  late UniqueKey lastBlockKey;

  int starsCollected = 0;
  int health = 3;

  @override
  Color backgroundColor() {
    return Color.fromARGB(255, 155, 210, 255);
  }

  @override
  Future<void> onLoad() async {
    await images.loadAll([
      'block.png',
      'mario.png',
      'ground.png',
      'heart_half.png',
      'heart.png',
      'coin.png',
      'mushroom.png',
    ]);
    SpriteComponent background = SpriteComponent()
      ..sprite = await loadSprite('clouds.png')
      ..size = size;

    add(background);
    initializeGame(true);
  }

  @override
  void update(double dt) {
    if (health <= 0) {
      overlays.add('GameOver');
    }
    super.update(dt);
  }

  void initializeGame(bool loadHud) {
    // Assume that size.x < 3200
    final segmentsToLoad = (size.x / 640).ceil();
    segmentsToLoad.clamp(0, segments.length);

    for (var i = 0; i <= segmentsToLoad; i++) {
      loadGameSegments(i, (640 * i).toDouble());
    }

    _ember = EmberPlayer(
      position: Vector2(128, canvasSize.y - 128),
    );
    add(_ember);
    if (loadHud) {
      add(Hud());
    }
  }

  void reset() {
    starsCollected = 0;
    health = 3;
    initializeGame(false);
  }

  void loadGameSegments(int segmentIndex, double xPositionOffset) {
    for (final block in segments[segmentIndex]) {
      switch (block.blockType) {
        case GroundBlock:
          add(GroundBlock(
            gridPosition: block.gridPosition,
            xOffset: xPositionOffset,
          ));
          break;
        case PlatformBlock:
          add(PlatformBlock(
            gridPosition: block.gridPosition,
            xOffset: xPositionOffset,
          ));
          break;
        case Star:
          add(Star(
            gridPosition: block.gridPosition,
            xOffset: xPositionOffset,
          ));
          break;
        case MushroomEnemy:
          add(MushroomEnemy(
            gridPosition: block.gridPosition,
            xOffset: xPositionOffset,
          ));
          break;
      }
    }
  }
}
