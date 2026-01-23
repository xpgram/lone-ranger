## The global event bus.
extends Node

@warning_ignore_start('UNUSED_SIGNAL')


## Emitted when the turn system's real-time count changes.
signal real_time_updated(time_remaining: float);

## Emitted when the turn system's golem-time count changes.
signal golem_time_updated(time_remaining: float);

## Emitted when the turn system completes a full round.
signal round_passed();

# FIXME AudioBus is a global autoload, why am I using Events for this?
#  AudioBus.play_one_shot() needs to return a reference to the instantiated object so it
#  can be cut early.
## Emitted when a sound object is created.
signal one_shot_sound_emitted(audio_scene: PackedScene);
