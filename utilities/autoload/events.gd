## The global event bus.
extends Node

@warning_ignore_start('UNUSED_SIGNAL')


## Emitted when the turn system's real-time count changes.
signal real_time_updated(time_remaining: float);

## Emitted when the turn system's golem-time count changes.
signal golem_time_updated(time_remaining: float);

## Emitted when the turn system completes a full round.
signal round_passed();
