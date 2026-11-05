import funkin.play.PlayState;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;

import funkin.play.event.SongEvent;
import funkin.data.song.SongData.SongEventData;
import funkin.data.event.SongEventSchema;
import funkin.data.event.SongEventSchema.SongEventFieldType;

class ColorScreenEventDefeat extends SongEvent
{
  var overlay:FlxSprite;
  var fadeTween:FlxTween;
  var holdTimer:FlxTimer;

  public function new()
  {
    super('ColorScreenDefeat');
  }

  public override function handleEvent(data:SongEventData):Void
  {
    if (PlayState.instance == null) return;

    var color = data.getString('color') ?? 'FFFFFF';
    var fadeInDuration = data.getFloat('fadeInDuration') ?? 0.3;
    var holdDuration = data.getFloat('holdDuration') ?? 0.5;
    var fadeOutDuration = data.getFloat('fadeOutDuration') ?? 0.3;

    var margin = 500;

    overlay = new FlxSprite();
    overlay.makeGraphic(FlxG.width + margin * 2, FlxG.height + margin * 2, FlxColor.fromString('#$color'));
    overlay.x = -margin;
    overlay.y = -margin;
    overlay.scrollFactor.set();
    overlay.cameras = [PlayState.instance.camHUD];
    overlay.alpha = 0;
    overlay.zIndex = 5000;
    var insertIndex = PlayState.instance.members.indexOf(PlayState.instance.playerStrumline);
    if (insertIndex == -1) insertIndex = PlayState.instance.members.length;
    PlayState.instance.insert(insertIndex, overlay);

    fadeTween = FlxTween.tween(overlay, {alpha: 1}, fadeInDuration, {
      onComplete: function(_)
      {
        holdTimer = new FlxTimer().start(holdDuration, function(_)
        {
          fadeTween = FlxTween.tween(overlay, {alpha: 0}, fadeOutDuration, {
            onComplete: function(_)
            {
              cleanup();
            }
          });
        });
      }
    });
  }

  function cleanup():Void
  {
    if (fadeTween != null)
    {
      fadeTween.cancel();
      fadeTween = null;
    }

    if (holdTimer != null)
    {
      holdTimer.cancel();
      holdTimer = null;
    }

    if (overlay != null)
    {
      if (PlayState.instance != null) PlayState.instance.remove(overlay, true);
      overlay.destroy();
      overlay = null;
    }
  }

  override function onSongRetry(event):Void
  {
    super.onSongRetry(event);
    cleanup();
  }

  public override function getTitle():String
  {
    return 'Color Screen [Defeat Port]';
  }

  public override function getEventSchema():SongEventSchema
  {
    return new SongEventSchema([{
      name: 'color',
      title: 'Color',
      defaultValue: 'FFFFFF',
      type: SongEventFieldType.STRING
    }, {
      name: 'fadeInDuration',
      title: 'Fade In Duration',
      defaultValue: 0.3,
      step: 0.1,
      type: SongEventFieldType.FLOAT,
      units: 'seconds'
    }, {
      name: 'holdDuration',
      title: 'Hold Duration',
      defaultValue: 0.5,
      step: 0.1,
      type: SongEventFieldType.FLOAT,
      units: 'seconds'
    }, {
      name: 'fadeOutDuration',
      title: 'Fade Out Duration',
      defaultValue: 0.3,
      step: 0.1,
      type: SongEventFieldType.FLOAT,
      units: 'seconds'
    }]);
  }
}