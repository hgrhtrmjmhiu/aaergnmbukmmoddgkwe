import funkin.play.PlayState;
import flixel.FlxG;
import flixel.util.FlxColor;

import funkin.play.event.SongEvent;
import funkin.data.song.SongData.SongEventData;
import funkin.data.event.SongEventSchema;
import funkin.data.event.SongEventSchema.SongEventFieldType;

class FlashScreenEventDefeat extends SongEvent
{
  public function new()
  {
    super('FlashScreenDefeat');
  }

  public override function handleEvent(data:SongEventData):Void
  {
    if (PlayState.instance == null) return;

    var color = data.getString('color') ?? 'FFFFFF';
    var duration = data.getFloat('duration') ?? 0.5;

    // Hace parpadear la pantalla
    FlxG.camera.flash(FlxColor.fromString('#$color'), duration);
  }

  public override function getTitle():String
  {
    return 'Flash Screen [Defeat Port]';
  }

  public override function getEventSchema():SongEventSchema
  {
    return new SongEventSchema([{
      name: 'color',
      title: 'Flash Color',
      defaultValue: 'FFFFFF',
      type: SongEventFieldType.STRING
    }, {
      name: 'duration',
      title: 'Duration',
      defaultValue: 0.5,
      step: 0.1,
      type: SongEventFieldType.FLOAT,
      units: 'seconds'
    }]);
  }
}