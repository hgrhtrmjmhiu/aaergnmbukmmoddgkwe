import funkin.play.PlayState;
import funkin.play.song.Song;
import funkin.Highscore;
import flixel.text.FlxText;
import flixel.text.FlxTextBorderStyle;
import flixel.FlxG;
import funkin.Paths;
import funkin.play.PauseSubState;

class DefeatSongScript extends Song
{
  public function new()
  {
    super('defeat');
  }

  // >>> EMPIEZA LO NUEVO
  // Antes era: static inline var MAX_MISSES:Int = 5;
  // Ahora el límite depende de la dificultad (easy = 5, normal = 4, hard = 3, erect = 2, nightmare = 0).
  var maxMisses:Int = 5;
  // <<< TERMINA LO NUEVO

  var ps:PlayState;
  var missText:FlxText;
  var alreadyKilled:Bool = false;

  // >>> EMPIEZA LO NUEVO
  function getMaxMissesForDifficulty():Int
  {
    var diff:String = '';
    try
    {
      diff = Std.string(PlayState.instance.currentDifficulty).toLowerCase();
    }
    catch (e:Dynamic)
    {
      trace('[DefeatSong] no se pudo leer la dificultad: ' + e);
    }

    trace('[DefeatSong] dificultad detectada: "' + diff + '"');

    switch (diff)
    {
      case 'easy':
        return 5;
      case 'normal':
        return 4;
      case 'hard':
        return 3;
      case 'erect':
        return 2;
      case 'nightmare':
        return 0;
      default:
        return 5; // dificultad desconocida: se usa el límite original
    }
  }
  // <<< TERMINA LO NUEVO

  override function onCreate(e)
  {
    super.onCreate(e);
    ps = PlayState.instance;
    alreadyKilled = false;

    // >>> EMPIEZA LO NUEVO
    maxMisses = getMaxMissesForDifficulty();
    // <<< TERMINA LO NUEVO

    PauseSubState.musicSuffix = '-defeat';

    if (ps.scoreText != null) ps.scoreText.visible = false;

    // Oculta la barra de vida y los íconos de salud.
    if (ps.healthBar != null) ps.healthBar.visible = false;
    if (ps.healthBarBG != null) ps.healthBarBG.visible = false;
    if (ps.iconP1 != null) ps.iconP1.visible = false;
    if (ps.iconP2 != null) ps.iconP2.visible = false;

    // >>> EMPIEZA LO NUEVO (MAX_MISSES -> maxMisses)
    missText = new FlxText(ps.healthBarBG.x, ps.healthBarBG.y + 13, ps.healthBarBG.width, "Score: 0 | Misses: 0/" + maxMisses, 22);
    // <<< TERMINA LO NUEVO
    missText.setFormat(Paths.font("vcr.ttf"), 22, 0xFFFF0000, 'center', FlxTextBorderStyle.OUTLINE, 0xFF000000);
    missText.borderColor = 0xFF000000;
    missText.borderSize = 2;
    missText.scrollFactor.set();
    missText.cameras = [ps.camHUD];
    missText.zIndex = 99999;
    ps.add(missText);

    centerPlayerStrumline();
    hideOpponentStrumline();
  }

  override function onUpdate(e)
  {
    super.onUpdate(e);
    if (ps == null) return;

    var misses = Highscore.tallies.missed;
    var score = Math.floor(ps.songScore);

    if (missText != null)
    {
      // >>> EMPIEZA LO NUEVO (MAX_MISSES -> maxMisses)
      missText.text = "Score: " + score + " | Misses: " + misses + "/" + maxMisses;
      // <<< TERMINA LO NUEVO
    }

    // >>> EMPIEZA LO NUEVO (MAX_MISSES -> maxMisses)
    if (misses > maxMisses && !alreadyKilled)
    // <<< TERMINA LO NUEVO
    {
      alreadyKilled = true;
      ps.health = -1;
    }
  }

  override function onSongRetry(event)
  {
    super.onSongRetry(event);
    alreadyKilled = false;

    // >>> EMPIEZA LO NUEVO
    maxMisses = getMaxMissesForDifficulty();
    // <<< TERMINA LO NUEVO

    PauseSubState.musicSuffix = '-defeat';

    if (ps != null && ps.scoreText != null) ps.scoreText.visible = false;
    if (ps != null && ps.healthBar != null) ps.healthBar.visible = false;
    if (ps != null && ps.healthBarBG != null) ps.healthBarBG.visible = false;
    if (ps != null && ps.iconP1 != null) ps.iconP1.visible = false;
    if (ps != null && ps.iconP2 != null) ps.iconP2.visible = false;

    centerPlayerStrumline();
    hideOpponentStrumline();
  }

  function centerPlayerStrumline():Void
  {
    var playerStrumline = PlayState.instance.playerStrumline;
    if (playerStrumline != null)
    {
      playerStrumline.x = FlxG.width / 2 - playerStrumline.width / 2;
      playerStrumline.zIndex = 99999;
    }
  }

  function hideOpponentStrumline():Void
  {
    var opponentStrumline = PlayState.instance.opponentStrumline;
    if (opponentStrumline != null)
    {
      opponentStrumline.visible = false;
      opponentStrumline.alpha = 0;

      if (opponentStrumline.members != null)
      {
        for (arrow in opponentStrumline.members)
        {
          if (arrow != null)
          {
            arrow.visible = false;
            arrow.alpha = 0;
          }
        }
      }
    }
  }
}