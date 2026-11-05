import funkin.play.stage.Stage;
import funkin.play.PlayState;
import funkin.play.GameOverSubState;
import funkin.audio.FunkinSound;
import funkin.Paths;
import funkin.Conductor;
import funkin.Constants;
import funkin.modding.events.ScriptEvent;
import flixel.FlxG;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.util.FlxTimer;

class Defeat2Stage extends Stage
{
  static inline var FADE_TIME:Float = 0.5;
  static inline var SCENE_DURATION:Float = 3.3;

  var ps:PlayState;
  var sequenceStarted:Bool = false;
  var allowFinalDeath:Bool = false;
  var dadSceneAnim:String = 'idle';

  function new()
  {
    super('defeat2');
  }

  override function onCreate(event:ScriptEvent):Void
  {
    super.onCreate(event);

    // Código original del stage.
    GameOverSubState.musicSuffix = '-defeat';
    GameOverSubState.blueBallSuffix = '-defeat';

    // Preparar la secuencia de muerte.
    ps = PlayState.instance;
    sequenceStarted = false;
    allowFinalDeath = false;
    dadSceneAnim = 'idle';
  }

  override function onNoteGhostMiss(event):Void
  {
    super.onNoteGhostMiss(event);

    // Código original: cancelar las ghost misses.
    event.cancel();
    event.stopPropagation();
  }

  override function onGameOver(event:ScriptEvent):Void
  {
    super.onGameOver(event);

    // >>> EMPIEZA LO NUEVO
    // Siempre trabajar con el PlayState actual (ps puede ser uno viejo/destruido).
    ps = PlayState.instance;

    if (allowFinalDeath)
    {
      // Restaurar el HUD antes del Game Over real; protegido por si la cámara ya no es válida.
      try
      {
        if (ps != null && ps.camHUD != null)
          ps.camHUD.alpha = 1;
      }
      catch (e:Dynamic)
      {
        trace('[Defeat2] camHUD.alpha falló en onGameOver: ' + e);
      }

      return;
    }
    // <<< TERMINA LO NUEVO

    if (sequenceStarted)
    {
      event.cancel();
      return;
    }

    // Evitar que el Game Over normal interrumpa la escena.
    event.cancel();
    sequenceStarted = true;

    if (ps == null)
      return;

    ps.isPlayerDying = true;
    ps.isInCutscene = true;

    // Enfocar a GF y aplicar el zoom.
    focusCameraOnGFAndZoom();

    // Mantener al oponente en idle hasta su animación de muerte.
    if (ps.currentStage != null)
    {
      var dad = ps.currentStage.getDad();

      if (dad != null)
      {
        dad.holdTimer = 0;
        dad.playAnimation('idle', true);
      }
    }

    // >>> EMPIEZA LO NUEVO
    // Cada llamada de audio va protegida: el "Null Object Reference" salía en ps.vocals.resume()
    // (línea 117 de tu versión). Si algún sonido del grupo de voces no es válido, ya no rompe la secuencia.
    // Desvanecer la música instrumental.
    if (FlxG.sound.music != null)
    {
      try { FlxG.sound.music.onComplete = function() {}; } catch (e:Dynamic) { trace('[Defeat2] music.onComplete falló: ' + e); }
      try { FlxG.sound.music.resume(); } catch (e:Dynamic) { trace('[Defeat2] music.resume falló: ' + e); }

      try
      {
        FlxTween.tween(FlxG.sound.music, {volume: 0}, FADE_TIME, {ease: FlxEase.linear});
      }
      catch (e:Dynamic) { trace('[Defeat2] fade música falló: ' + e); }
    }

    // Desvanecer las voces.
    if (ps.vocals != null)
    {
      try { ps.vocals.resume(); } catch (e:Dynamic) { trace('[Defeat2] vocals.resume falló: ' + e); }

      try
      {
        FlxTween.tween(ps.vocals, {playerVolume: 0, opponentVolume: 0}, FADE_TIME, {ease: FlxEase.linear});
      }
      catch (e:Dynamic) { trace('[Defeat2] fade voces falló: ' + e); }
    }
    // <<< TERMINA LO NUEVO

    // Ocultar el HUD durante la escena.
    if (ps.camHUD != null)
    {
      FlxTween.tween(
        ps.camHUD,
        {alpha: 0},
        FADE_TIME,
        {ease: FlxEase.linear}
      );
    }

    // Sonido inicial de la secuencia.
    FunkinSound.playOnce(Paths.sound('defeat_prekill_sfx'));

    // Pausar el audio cuando termine el fundido.
    new FlxTimer().start(FADE_TIME, function(_)
    {
      // >>> EMPIEZA LO NUEVO
      try { if (FlxG.sound.music != null) FlxG.sound.music.pause(); } catch (e:Dynamic) { trace('[Defeat2] music.pause falló: ' + e); }
      try { if (ps != null && ps.vocals != null) ps.vocals.pause(); } catch (e:Dynamic) { trace('[Defeat2] vocals.pause falló: ' + e); }
      // <<< TERMINA LO NUEVO
    });

    // Primera animación de muerte del oponente.
    new FlxTimer().start(0.22, function(_)
    {
      if (ps == null || ps.currentStage == null)
        return;

      var dad = ps.currentStage.getDad();

      dadSceneAnim = 'kill';

      if (dad != null)
        dad.playAnimation('kill', true);
    });

    // Segunda animación de muerte.
    new FlxTimer().start(1.80, function(_)
    {
      if (ps == null || ps.currentStage == null)
        return;

      var dad = ps.currentStage.getDad();

      dadSceneAnim = 'kill2';

      if (dad != null)
        dad.playAnimation('kill2', true);
    });

    // Al terminar la escena, permitir el Game Over normal.
    new FlxTimer().start(SCENE_DURATION, function(_)
    {
      if (ps == null)
        return;

      allowFinalDeath = true;
      ps.isInCutscene = false;
      ps.isPlayerDying = false;
    });
  }

  function focusCameraOnGFAndZoom():Void
  {
    if (ps == null || ps.currentStage == null)
      return;

    var gf = ps.currentStage.getGirlfriend();

    if (gf == null)
      return;

    ps.resetCamera(false, false, false);
    ps.cancelCameraFollowTween();

    ps.cameraFollowPoint.setPosition(
      gf.cameraFocusPoint.x,
      gf.cameraFocusPoint.y
    );

    var durationSeconds =
      Conductor.instance.stepLengthMs * 7 / Constants.MS_PER_SEC;

    ps.tweenCameraZoom(
      0.6,
      durationSeconds,
      true,
      FlxEase.quadInOut
    );
  }

  override function onSongEvent(event):Void
  {
    super.onSongEvent(event);

    // Evitar que eventos de la canción interfieran con la escena.
    if (sequenceStarted && !allowFinalDeath)
      event.cancel();
  }

  override function onSongRetry(event):Void
  {
    super.onSongRetry(event);

    // >>> EMPIEZA LO NUEVO
    // Tras reintentar, PlayState es una instancia nueva: la referencia vieja (ps) apunta a una
    // cámara destruida, de ahí el "Invalid access to field alpha". Se refresca y se protege cada acceso.
    ps = PlayState.instance;

    sequenceStarted = false;
    allowFinalDeath = false;
    dadSceneAnim = 'idle';

    try
    {
      if (ps != null)
      {
        ps.isInCutscene = false;
        ps.isPlayerDying = false;

        if (ps.camHUD != null)
        {
          FlxTween.cancelTweensOf(ps.camHUD);
          ps.camHUD.alpha = 1;
        }

        if (ps.vocals != null)
        {
          FlxTween.cancelTweensOf(ps.vocals);
          ps.vocals.playerVolume = 1;
          ps.vocals.opponentVolume = 1;
        }
      }
    }
    catch (e:Dynamic)
    {
      trace('[Defeat2] restaurar estado en onSongRetry falló: ' + e);
    }

    try
    {
      if (FlxG.sound.music != null)
      {
        FlxTween.cancelTweensOf(FlxG.sound.music);
        FlxG.sound.music.volume = 1;
      }
    }
    catch (e:Dynamic)
    {
      trace('[Defeat2] restaurar música en onSongRetry falló: ' + e);
    }
    // <<< TERMINA LO NUEVO

    // Conservar la configuración original y adicional.
    GameOverSubState.musicSuffix = '-defeat';
    GameOverSubState.blueBallSuffix = '-defeat';
  }
}