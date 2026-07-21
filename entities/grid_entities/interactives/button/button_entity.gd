## A floor-button entity that is compressed when something heavy is placed over the same
## [Grid] tile. Emits signals when it is pressed and released.
class_name ButtonEntity
extends Interactive2D


const _scene_click_in_audio := preload('uid://d36imc25otxdj');
const _scene_click_out_audio := preload('uid://nrlqhbx0http');


## Emitted when this button is first pressed or 'powered on'. [br]
##
## [b]Note:[/b] This signal exists primarily to serve button systems. The
## preferred method for button interoperability is to set a [PowerableComponent]
## on an object and set that object as a target of this button with
## [member _powerable_targets].
signal pressed();

## Emitted when this button is first released or 'powered off'. [br]
##
## [b]Note:[/b] This signal exists primarily to serve button systems. The
## preferred method for button interoperability is to set a [PowerableComponent]
## on an object and set that object as a target of this button with
## [member _powerable_targets].
signal released();


## A list of [Node]s to toggle in accordance with this button's
## [member is_pressed] state. All referenced [Node]s must own a
## [PowerableComponent] to be notified of changes.
@export var _powerable_targets := [] as Array[Node];

## Whether the button is currently being pressed down. [br]
##
## Setting this value will immediately notify listeners of the state change. [br]
##
## If [member stays_pressed] is `true`, this value cannot be set to `false`
## after it has been set to `true`.
@export var is_pressed: bool:
  set(value):
    if (
        value == is_pressed
        or is_pressed and stays_pressed
    ):
      return;

    is_pressed = value;

    var sprite_texture_key := 'pressed' if is_pressed else 'neutral';
    var sound_to_play := _scene_click_in_audio if is_pressed else _scene_click_out_audio;
    var signal_to_emit := pressed if is_pressed else released;

    _sprite.texture_key = sprite_texture_key;
    Events.one_shot_sound_emitted.emit(sound_to_play);
    signal_to_emit.emit();
    _notify_powerable_targets();
    _update_persistence_key();

## Whether this button remains in its 'pressed' state even after being released.
@export var stays_pressed := false;

## @nullable [br]
## The [PersistenceKeyBool] object to set along with this button's
## [member is_pressed] state. If this object is null, no persistence key is set.
@export var _persistence_key: PersistenceKeyBool;


## A reference to the button's sprite object.
@onready var _sprite := %MultiSprite2D as MultiSprite2D;


func _bind_stimulus_callbacks() -> void:
  super._bind_stimulus_callbacks();
  _stimulus_event_map.add_events({
    Stimulus.object_collision: _on_object_collision,
    Stimulus.object_separation: _on_object_separation,
  });


## Handler for object grid-collision events.
func _on_object_collision(entity: GridEntity) -> void:
  if is_pressed or not _entity_can_press_button(entity):
    return;

  is_pressed = true;


## Handler for object grid-separation events.
func _on_object_separation(_entity: GridEntity) -> void:
  if not is_pressed:
    return;

  var tile_entities := Grid.get_entities(grid_position);
  var heavy_entities := tile_entities.filter(func (tile_entity: GridEntity):
    return tile_entity != self and _entity_can_press_button(tile_entity)
  ) as Array[GridEntity];

  is_pressed = (heavy_entities.size() == 0);


## Returns true if the given entity is of a kind that is capable of pressing
## this button.
func _entity_can_press_button(entity: GridEntity) -> bool:
  return entity.solid;


## Updates the powered state of all [PowerableComponent]s found in this button's
## list of [member _powerable_targets] to match this button's
## [member is_pressed] state.
func _notify_powerable_targets() -> void:
  if not _powerable_targets:
    return;

  for target in _powerable_targets:
    var powerable := Component.getc(target, PowerableComponent) as PowerableComponent;
    if powerable:
      powerable.powered = is_pressed;


## Updates the state of the [member _persistence_key] associated with this
## button to match its [member is_pressed] state.
func _update_persistence_key() -> void:
  if not _persistence_key:
    return;

  _persistence_key.write(is_pressed);
