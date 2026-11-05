import funkin.data.stage.StageRegistry;
import funkin.play.event.SongEvent;
import funkin.play.PlayState;
import funkin.play.character.CharacterDataParser;
import funkin.play.character.CharacterType;
import funkin.play.character.BaseCharacter;
import flixel.FlxG;
import haxe.ds.StringMap;

/**
 * Evento simple para cambiar el stage mid-song.
 */
class ChangeStageEventDefeat extends SongEvent
{
  public function new()
  {
    super('ChangeStageDefeat');
  }

  public override function handleEvent(data:SongEventData):Void
  {
    var stageID:String = data.value.stageid ?? 'mainStage';
    swapStage(stageID);
  }

  public override function getTitle():String
  {
    return "Change Stage [Defeat Port]";
  }

  public override function getEventSchema()
  {
    return [
      {
        name: "stageid",
        title: "Stage",
        defaultValue: "mainStage",
        type: "enum",
        keys: generateStageList()
      }
    ];
  }

  function generateStageList():StringMap<String>
  {
    var stageIDs:Array<String> = StageRegistry.instance.listEntryIds();
    var stageMap:StringMap<String> = new StringMap();

    for (stage in stageIDs)
    {
      stageMap.set(stage, stage);
    }
    return stageMap;
  }

  function swapStage(stageID:String):Void
  {
    if (PlayState.instance == null || PlayState.instance.currentStage == null) return;
    if (PlayState.instance.isMinimalMode) return;

    var bfId = PlayState.instance.currentStage.getBoyfriend()?.characterId;
    var gfId = PlayState.instance.currentStage.getGirlfriend()?.characterId;
    var dadId = PlayState.instance.currentStage.getDad()?.characterId;

    // Limpia filtros como el shader de lluvia del Weekend 1.
    FlxG.camera.filters = [];

    PlayState.instance.remove(PlayState.instance.currentStage);
    PlayState.instance.currentStage.kill();
    for (sprite in PlayState.instance.currentStage.group)
    {
      if (sprite != null)
      {
        sprite.kill();
        PlayState.instance.currentStage.group.remove(sprite);
      }
    }
    PlayState.instance.currentStage = null;

    PlayState.instance.currentStage = StageRegistry.instance.fetchEntry(stageID);

    if (PlayState.instance.currentStage == null) return;

    PlayState.instance.currentStage.revive();
    PlayState.instance.resetCameraZoom();
    PlayState.instance.currentStage.buildStage();
    PlayState.instance.add(PlayState.instance.currentStage);

    var bf:BaseCharacter = CharacterDataParser.fetchCharacter(bfId);
    var gf:BaseCharacter = CharacterDataParser.fetchCharacter(gfId);
    var dad:BaseCharacter = CharacterDataParser.fetchCharacter(dadId);

    if (bf != null)
    {
      bf.initHealthIcon(true);
      PlayState.instance.currentStage.addCharacter(bf, CharacterType.BF);
    }

    if (gf != null)
    {
      PlayState.instance.currentStage.addCharacter(gf, CharacterType.GF);
    }

    if (dad != null)
    {
      dad.initHealthIcon(true);
      PlayState.instance.currentStage.addCharacter(dad, CharacterType.DAD);
    }

    PlayState.instance.currentStage.resetStage();
    PlayState.instance.currentStage.refresh();
  }
}