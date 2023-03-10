import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import '../mario_quest.dart';

class EndTopBlock extends SpriteComponent with HasGameRef<marioQuestGame> {
  final Vector2 gridPosition;
  double xOffset;
  final Vector2 velocity = Vector2.zero();

  EndTopBlock({
    required this.gridPosition,
    required this.xOffset,
  }) : super(size: Vector2.all(64), anchor: Anchor.bottomLeft);

  @override
  Future<void> onLoad() async {
    final platformImage = game.images.fromCache('top_flag.png');
    sprite = Sprite(platformImage);
    position = Vector2(
      (gridPosition.x * size.x) + xOffset,
      game.size.y - (gridPosition.y * size.y),
    );
    add(RectangleHitbox()..collisionType = CollisionType.passive);
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
