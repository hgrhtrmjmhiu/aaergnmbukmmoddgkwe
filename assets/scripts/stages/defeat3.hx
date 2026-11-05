import funkin.play.stage.Stage;
import funkin.play.GameOverSubState;
import funkin.modding.events.ScriptEvent;

class Defeat3Stage extends Stage
{
  function new()
  {
    super('defeat3');
  }

  override function onNoteGhostMiss(event):Void
  {
    super.onNoteGhostMiss(event);

    event.cancel();
    event.stopPropagation();
  }
}