package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxRandom;
import flixel.util.FlxTimer;

class PlayState extends FlxState
{
  var playerProjectileGroup:FlxSpriteGroup;
  var playerLaserGroup:FlxSpriteGroup;

  var enemyProjectileGroup:FlxSpriteGroup;
  var enemyLaserGroup:FlxSpriteGroup;

  var enemyGroup:FlxSpriteGroup;
  var enemyExplosionGroup:FlxSpriteGroup;
  var pipes:WallPipes;

  var spawnGroup:SpawnGroup;
  var player:Player;

  var level:Room;
  var slime:Slime;

  override public function create():Void {
    super.create();
    Reg.random = new FlxRandom();
    Reg.started = false;

    playerProjectileGroup = new FlxSpriteGroup();
    playerLaserGroup = new FlxSpriteGroup();

    enemyProjectileGroup = new FlxSpriteGroup();
    enemyLaserGroup = new FlxSpriteGroup();
    enemyGroup = new FlxSpriteGroup();
    enemyExplosionGroup = new FlxSpriteGroup();
    
    Reg.enemyGroup = enemyGroup;
    Reg.enemyExplosionService = new EnemyExplosionService(enemyExplosionGroup);

    Reg.playerProjectileService = new ProjectileService(playerProjectileGroup);
    Reg.playerLasesrService = new LaserService(playerLaserGroup);

    Reg.enemyProjectileService = new ProjectileService(enemyProjectileGroup, "enemy");
    Reg.enemyLaserService = new EnemyLaserService(enemyLaserGroup);

    level = new Room("assets/tilemaps/level.tmx");
    add(level.backgroundTiles);

    spawnGroup = new SpawnGroup();
    add(spawnGroup);

    player = new Player(spawnGroup.x + 6, spawnGroup.y + 6);
    player.init();
    add(player);

    add(enemyGroup);

    add(playerLaserGroup);
    add(enemyLaserGroup);

    add(new OozeGlow());

    add(level.foregroundTiles);

    pipes = new WallPipes();
    add(pipes);

    slime = new Slime();
    add(slime);

    add(playerProjectileGroup);
    add(enemyProjectileGroup);

    add(enemyExplosionGroup);

    //DEBUGGER
    FlxG.debugger.drawDebug = true;
  }

  override public function destroy():Void {
    super.destroy();
  }

  override public function update(elapsed:Float):Void {
    if (player.started) spawnGroup.exists = false;
    level.collideWithLevel(player);
    level.collideWithLevel(playerProjectileGroup, Projectile.handleCollision);
    level.collideWithLevel(enemyProjectileGroup, Projectile.handleCollision);

    FlxG.overlap(slime, enemyProjectileGroup, Projectile.handleCollision);
    FlxG.overlap(slime, playerProjectileGroup, Projectile.handleCollision);
    FlxG.overlap(enemyLaserGroup, playerProjectileGroup, Projectile.handleCollision);
    FlxG.overlap(playerLaserGroup, enemyProjectileGroup, Projectile.handleCollision);

    FlxG.overlap(pipes, playerProjectileGroup, function(pipe, projectile):Void {
      Projectile.handleCollision(pipe, projectile);
      cast(pipe, Pipe).hurt(1);
    });

    FlxG.overlap(player, enemyProjectileGroup, function(player, projectile):Void {
      Projectile.handleCollision(player, projectile);
      cast(player, Player).die();
      FlxG.camera.flash(0xff33ff88, 0.5);
      spawnGroup.exists = true;
      player.x = spawnGroup.x + 6;
      player.y = spawnGroup.y + 6;
    });

    FlxG.overlap(player, enemyLaserGroup, function(player, laser):Void {
      cast(player, Player).die();
      FlxG.camera.flash(0xff33ff88, 0.5);
      spawnGroup.exists = true;
      player.x = spawnGroup.x + 6;
      player.y = spawnGroup.y + 6;
    });
    
    super.update(elapsed);
  }
}
