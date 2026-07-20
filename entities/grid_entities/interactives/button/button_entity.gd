## A floor-button entity that is compressed when something heavy is placed over the same
## [Grid] tile. Emits signals when it is pressed and released.
class_name ButtonEntity
extends Interactive2D


const _scene_click_in_audio := preload('uid://d36imc25otxdj');
const _scene_click_out_audio := preload('uid://nrlqhbx0http');


## Emitted when the button is pressed by some heavy object.
signal pressed();

## Emitted when all heavy objects leave the button's [Grid] location and it is no longer
## being held down.
signal released();


## If enabled, the button is pressable once and will not release even when freed.
@export var _stays_pressed := false;

## A list of [Node] objects that may have a [PowerableComponent] to toggle
## in accordance with this button's state.
@export var _powerable_targets := [] as Array[Node];


@export_group('Persistence Key')

## @nullable [br]
## The [PersistenceKeyBool] object to set along with this button entity's
## pressed state. If this object is null, no persistence key is set.
@export var _persistence_key: PersistenceKeyBool;


## Whether the button is currently being pressed down.
var is_pressed := false:
  set(value):
    var old_value := is_pressed;
    is_pressed = value;

    if (
        old_value == is_pressed
        or is_pressed and _stays_pressed
    ):
      return;

    var sprite_texture_key := 'pressed' if is_pressed else 'neutral';
    var sound_to_play := _scene_click_in_audio if is_pressed else _scene_click_out_audio;
    var virtual_to_call := _on_pressed if is_pressed else _on_released;
    var signal_to_emit := pressed if is_pressed else released;

    _sprite.texture_key = sprite_texture_key;
    Events.one_shot_sound_emitted.emit(sound_to_play);
    virtual_to_call.call();
    _notify_powerable_targets();
    signal_to_emit.emit();
    _update_persistence_key();


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


## @virtual [br]
## Override to add on-pressed behavior to this [ButtonEntity].
func _on_pressed() -> void:
  pass


## @virtual [br]
## Override to add on-released behavior to this [ButtonEntity].
func _on_released() -> void:
  pass


## Returns true if the given entity is of a kind that is capable of pressing
## this button.
func _entity_can_press_button(entity: GridEntity) -> bool:
  return entity.solid;


## Tries to set the powered state of a [PowerableComponent] on each powerable-
## target known to this button entity.
func _notify_powerable_targets() -> void:
  if not _powerable_targets:
    return;

  for target in _powerable_targets:
    var powerable := Component.getc(target, PowerableComponent) as PowerableComponent;
    if powerable:
      powerable.powered = is_pressed;


## Tries to update the state of the [member _persistence_key] associated with
## this button entity.
func _update_persistence_key() -> void:
  if not _persistence_key:
    return;

  _persistence_key.write(is_pressed);
