## A floor-button entity that is compressed when something heavy is placed over the same
## [Grid] tile. Emits signals when it is pressed and released.
class_name ButtonEntity
extends Interactive2D


const _scene_click_in_audio := preload('uid://d36imc25otxdj');
const _scene_click_out_audio := preload('uid://nrlqhbx0http');


## A list of [Node] objects that may have a [PowerableComponent] to toggle
## in accordance with this button's state.
@export var _powerable_targets := [] as Array[Node]:
  set(value):
    _powerable_targets = value;
    _button_logic.set_powerable_targets(_powerable_targets);


## The press/release and listener-notification handler for this ButtonEntity.
@export var _button_logic := ButtonStateLogic.new():
  set(value):
    _button_logic = value if value else ButtonStateLogic.new();


## Whether the button is currently being pressed down.
var is_pressed: bool:
  get():
    return _button_logic.is_activated;
  set(value):
    _button_logic.is_activated = value;

    var sprite_texture_key := 'pressed' if is_pressed else 'neutral';
    var sound_to_play := _scene_click_in_audio if is_pressed else _scene_click_out_audio;

    _sprite.texture_key = sprite_texture_key;
    Events.one_shot_sound_emitted.emit(sound_to_play);


@onready var _sprite := %MultiSprite2D as MultiSprite2D;


## Returns this button entity's state logic resource. [br]
##
## [b]Note:[/b] While this method may be used to get access to the button's 'on'
## and 'off' signals, the preferred method for button interoperability is to set
## a [PowerableComponent] on an object and set that object as a target of this
## button with [member _powerable_targets].
func get_button_logic() -> ButtonStateLogic:
  return _button_logic;


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
