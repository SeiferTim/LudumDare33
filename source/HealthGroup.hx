package;

import flixel.group.FlxSpriteGroup;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.util.FlxTimer;
import flixel.FlxObject;

import flixel.math.FlxVector;
import flixel.math.FlxMath;

class HealthGroup extends FlxSpriteGroup {
  var spawnTimer:Float = 5;

  public function new() {
    super();
  }

  override public function update(elapsed:Float):Void {
    if (Reg.started) {
      spawnTimer -= elapsed;
      if (spawnTimer < 0) {
        spawnTimer = Reg.random.float(
          FlxMath.lerp(15, 10, Reg.difficulty),
          FlxMath.lerp(20, 15, Reg.difficulty)
        );
        var g = recycle(Health);
        cast(g, Health).spawn();
        add(g);
      }
    }

    super.update(elapsed);
  }
}
