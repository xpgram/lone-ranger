## A solid, unmovable block raised from the ground. [br]
##
## As these are usually player-made, they can be destroyed by bumping them a few times.
class_name RaisedBlockEntity
extends GridEntity


const RECOVERY_PER_ROUND := 1;
const DAMAGE_PER_BUMP := 2;
const BUMP_DAMAGE_TO_DESTROY := 4;

const _block_rising_audio_scene := preload('uid://caud4wfb4q3ty');

## The accumulated bump damage.
var _bump_damage := 0;


func _ready() -> void:
  super._ready();
  _bind_event_handlers();

  Events.one_shot_sound_emitted.emit(_block_rising_audio_scene);


func _bind_event_handlers() -> void:
  Events.round_passed.connect(_on_round_passed);


func _bind_stimulus_callbacks() -> void:
  super._bind_stimulus_callbacks();

  _stimulus_event_map.add_events({
    Stimulus.bumped: _on_bumped,
  });


## Uses the turn system to measure the recovery of bump damage over time.
func _on_round_passed() -> void:
  _bump_damage = max(0, _bump_damage - RECOVERY_PER_ROUND);


## Damages the block when bumped.
func _on_bumped() -> void:
  _bump_damage += DAMAGE_PER_BUMP;

  if _bump_damage >= BUMP_DAMAGE_TO_DESTROY:
    queue_free();
