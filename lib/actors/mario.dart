import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flameflutter/actors/mushroom_enemy.dart';
import 'package:flameflutter/objects/end_block.dart';
import 'package:flameflutter/objects/ground_block.dart';
import 'package:flameflutter/objects/platform_block.dart';
import 'package:flameflutter/objects/coin.dart';
import 'package:flutter/services.dart';

import '../mario_quest.dart';

class MarioPlayer extends SpriteAnimationComponent
    with KeyboardHandler, CollisionCallbacks, HasGameRef<marioQuestGame> {
  MarioPlayer({
    required super.position,
  }) : super(size: Vector2(64, 108), anchor: Anchor.center);

  int horizontalDirection = 0;
  final Vector2 velocity = Vector2.zero();
  double moveSpeed = 200;
  final Vector2 fromAbove = Vector2(0, -1);
  bool isOnGround = false;
  final double gravity = 35;
  final double jumpSpeed = 600;
  final double terminalVelocity = 250;

  bool hasJumped = false;

  bool hitByEnemy = false;

  bool runEndAnimation = false;

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    print('original_position: $position');
    if (other is GroundBlock || other is PlatformBlock) {
      if (intersectionPoints.length == 2) {
        // Calculate the collision normal and separation distance.
        final mid = (intersectionPoints.elementAt(0) +
                intersectionPoints.elementAt(1)) /
            2;

        final collisionNormal = absoluteCenter - mid;
        final separationDistance =
            ((size.y / 2) + 6.5) - collisionNormal.length;
        collisionNormal.normalize();

        // If collision normal is almost upwards,
        // ember must be on ground.
        if (fromAbove.dot(collisionNormal) > 0.9) {
          isOnGround = true;
        }

        // Resolve collision by moving ember along
        // collision normal by separation distance.
        position += collisionNormal.scaled(separationDistance);
      }
    }

    if (other is Coin) {
      other.removeFromParent();
      game.starsCollected++;
    }

    if (other is MushroomEnemy) {
      hit();
    }

    if (other is EndBlock && !game.endGame) {
      finishGame();
    }

    super.onCollision(intersectionPoints, other);
  }

  void finishGame() {
    moveSpeed = 0;
    animation?.loop = false;
    game.endGame = true;
  }

  // This method runs an opacity effect on mario
// to make it blink.
  void hit() {
    if (!hitByEnemy) {
      // game.health--;
      hitByEnemy = true;
    }
    add(
      OpacityEffect.fadeOut(
        EffectController(
          alternate: true,
          duration: 0.1,
          repeatCount: 6,
        ),
      )..onComplete = () {
          hitByEnemy = false;
        },
    );
  }

  @override
  void update(double dt) {
    velocity.x = horizontalDirection * moveSpeed;
    game.objectSpeed = 0;
    // Prevent mario from going backwards at screen edge.
    if (position.x - 36 <= 0 && horizontalDirection < 0) {
      velocity.x = 0;
    }
    // Prevent mario from going beyond half screen.
    if (position.x + 64 >= game.size.x / 2 && horizontalDirection > 0) {
      velocity.x = 0;
      game.objectSpeed = -moveSpeed;
    }

    // Apply basic gravity.
    velocity.y += gravity;

    // Determine if mario has jumped.
    if (hasJumped) {
      if (isOnGround) {
        velocity.y = -jumpSpeed;
        isOnGround = false;
      }
      hasJumped = false;
    }

    // Prevent mario from jumping to crazy fast.
    velocity.y = velocity.y.clamp(-jumpSpeed, terminalVelocity);

    // Adjust mario position.
    position += velocity * dt;

    // If mario fell in pit, then game over.
    if (position.y > game.size.y + size.y) {
      game.health = 0;
    }

    if (game.health <= 0) {
      removeFromParent();
    }

    // Flip mario if needed.
    if (horizontalDirection < 0 && scale.x > 0) {
      flipHorizontally();
    } else if (horizontalDirection > 0 && scale.x < 0) {
      flipHorizontally();
    }

    if (game.endGame && !runEndAnimation) {
      endGameAnimation();
      runEndAnimation = true;
    }
    super.update(dt);
  }

  @override
  bool onKeyEvent(RawKeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (game.endGame) {
      return false;
    }

    horizontalDirection = 0;
    horizontalDirection += (keysPressed.contains(LogicalKeyboardKey.keyA) ||
            keysPressed.contains(LogicalKeyboardKey.arrowLeft))
        ? -1
        : 0;
    horizontalDirection += (keysPressed.contains(LogicalKeyboardKey.keyD) ||
            keysPressed.contains(LogicalKeyboardKey.arrowRight))
        ? 1
        : 0;
    hasJumped = keysPressed.contains(LogicalKeyboardKey.space);

    return true;
  }

  @override
  Future<void> onLoad() async {
    animation = SpriteAnimation.fromFrameData(
      game.images.fromCache('mario.png'),
      SpriteAnimationData.sequenced(
        amount: 5,
        textureSize: Vector2(16, 27),
        stepTime: 0.12,
      ),
    );

    add(RectangleHitbox(size: size)..collisionType = CollisionType.active);
  }

  void endGameAnimation() {
    add(
      MoveEffect.by(
        Vector2(size.x * 5, 1),
        EffectController(
          duration: 3,
          startDelay: 1.5,
        ),
      ),
    );
    add(
      OpacityEffect.fadeOut(
        EffectController(
          duration: 0.1,
          startDelay: 3.5,
        ),
      ),
    );
  }
}
