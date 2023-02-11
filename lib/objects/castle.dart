import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import '../ember_quest.dart';

class Castle extends SpriteComponent with HasGameRef<EmberQuestGame> {
  final Vector2 gridPosition;
  double xOffset;
  final Vector2 velocity = Vector2.zero();

  Castle({
    required this.gridPosition,
    required this.xOffset,
  }) : super(size: Vector2.all(512), anchor: Anchor.topCenter);

  @override
  Future<void> onLoad() async {
    final platformImage = game.images.fromCache('castle.png');
    sprite = Sprite(platformImage);
    position = Vector2((gridPosition.x * size.x) + xOffset,
        game.size.y - (gridPosition.y * size.y) - 60);
  }

  @override
  void update(double dt) {
    velocity.x = game.objectSpeed;
    position += velocity * dt;
    if (position.x < -size.x) removeFromParent();
    super.update(dt);

    if (position.x < -size.x || game.health <= 0) {
      removeFromParent();
    }
  }
}
