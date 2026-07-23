## A trigger-node to call some behavior or set a [PersistenceKey] when the
## player has interacted with some set of objects.
class_name InteractionTrigger
extends Node


enum WatchMode {
  ## Any observed object will activate this trigger.
  Any,
  ## All observed objects must be interacted with once to activate this trigger.
  All,
}

enum TriggerTiming {
  ## Trigger activates before the player interaction has started.
  Before,
  ## Trigger activates after the player interaction has completed.
  After,
}


## Emitted when this trigger's preconditions are first met.
signal activated();

## Emitted when this trigger is reset.
signal deactivated();


## A list of [GridObject]s that, when interacted with by the player, should
## activate this trigger.
@export var _watched_objects := [] as Array[GridObject];

## Which activation method to use while observing the [member _watched_objects].
@export var _watch_mode := WatchMode.Any;

## When to activate this trigger, if it should activate.
@export var _trigger_timing := TriggerTiming.Before;

## @nullable [br]
## A persistence key to set when this trigger is activated.
@export var _persistence_key: PersistenceKeyBool;


## A list of objects known to have been interacted with by the player.
var _seen_objects := {} as Dictionary[GridObject, bool];

## Whether this trigger has formally signaled its activation. Used to prevent
## double-triggers by subsequent interactions.
var _has_activated := false;


func _ready() -> void:
  var player_interaction_event := (
    Events.player_interacting_with if _trigger_timing == TriggerTiming.Before
    else Events.player_interacted_with
  );

  player_interaction_event.connect(_on_player_interacted_with);

  if _persistence_key:
    _has_activated = _persistence_key.read();


## Resets this interaction trigger to baseline: not activated and no observed
## interactions.
func reset() -> void:
  _seen_objects = {};
  _set_activated(false);


## Handler for the event that the player has interacted with some object.
func _on_player_interacted_with(object: GridObject) -> void:
  if object in _watched_objects:
    _object_seen(object);


## Adds an object to a repository of seen objects.
func _object_seen(object: GridObject) -> void:
  _seen_objects[object] = true;
  _try_activate_trigger();


## Checks the trigger's state against its preconditions, and if met, activates
## the trigger.
func _try_activate_trigger() -> void:
  if _has_activated:
    return;

  match _watch_mode:
    WatchMode.Any:
      if _seen_objects.size() > 0:
        _set_activated();
    WatchMode.All:
      if _seen_objects.size() == _watched_objects.size():
        _set_activated();


## Sets this trigger's activation state. Calls and signals activation handlers
## when the activation state is successfully changed.
func _set_activated(is_activated := true) -> void:
  if _has_activated == is_activated:
    return;

  var to_call := _on_activated if is_activated else _on_deactivated;
  var to_signal := activated if is_activated else deactivated;

  to_call.call();
  to_signal.emit();

  _has_activated = is_activated;
  _update_persistence_key();


## @virtual [br]
## Override to add behavior to execute when this trigger is activated.
func _on_activated() -> void:
  pass


## @virtual [br]
## Override to add behavior to execute when this trigger is deactivated.
func _on_deactivated() -> void:
  pass


## Updates the persistence key to reflect the trigger's activation state.
func _update_persistence_key() -> void:
  if _persistence_key:
    _persistence_key.write(_has_activated);
