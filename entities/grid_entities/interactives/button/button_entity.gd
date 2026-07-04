## A floor-button entity that is compressed when something heavy is placed over the same
## [Grid] tile. Emits signals when it is pressed and released.
class_name ButtonEntity
extends Interactive2D


# [TODO] Button is missing sound effects.


## Emitted when the button is pressed by some heavy object.
signal pressed();

## Emitted when all heavy objects leave the button's [Grid] location and it is no longer
## being held down.
signal released();


## If enabled, the button is pressable once and will not release even when freed.
@export var _stays_pressed := false;


@export_group('Persistence Key')

# [TODO] Should this be a resource? 'null' would do nothing, obvi; anything else would
#   have a simple interface.
#   The persistence_key could be initialized with a prefix for specific objects, but
#   would otherwise generate a random default name. But how would it guarantee uniqueness?
## [IMPLEMENT]
@export var _sets_persistence_key := false;

## [IMPLEMENT]
@export var _persistence_key: StringName;


## Whether the button is currently being pressed down.
var _is_pressed := false;


@onready var _sprite := %MultiSprite2D as MultiSprite2D;


func _ready() -> void:
  super._ready();
  _connect_to_own_signals();


func _bind_stimulus_callbacks() -> void:
  super._bind_stimulus_callbacks();
  _stimulus_event_map.add_events({
    Stimulus.object_collision: _on_object_collision,
    Stimulus.object_separation: _on_object_separation,
  });


## Connects callbacks to this object's own signals.
func _connect_to_own_signals() -> void:
  pressed.connect(_on_pressed);
  released.connect(_on_released);


## Handler for object grid-collision events.
func _on_object_collision(_entity: GridEntity) -> void:
  press();


## Handler for object grid-separation events.
func _on_object_separation(_entity: GridEntity) -> void:
  if not _is_pressed:
    return;
  
  var tile_entities := Grid.get_entities(grid_position);
  var solid_entities := tile_entities.filter(func (entity: GridEntity):
    return entity.solid and entity != self;
  ) as Array[GridEntity];

  if solid_entities.size() == 0:
    release();


## 'Presses' the button, which changes its visuals and emits [signal pressed].
func press() -> void:
  if _is_pressed:
    return;

  _is_pressed = true;
  _sprite.texture_key = 'pressed';
  pressed.emit();


## 'Releases' the button, which changes its visuals and emits [signal released].
func release() -> void:
  if not _is_pressed or _stays_pressed:
    return;

  _is_pressed = false;
  _sprite.texture_key = 'neutral';
  released.emit();


## Returns true if this button is currently being held down.
func is_pressed() -> bool:
  return _is_pressed;


## @virtual [br]
## Override to add on-pressed behavior to this [ButtonEntity].
func _on_pressed() -> void:
  pass


## @virtual [br]
## Override to add on-released behavior to this [ButtonEntity].
func _on_released() -> void:
  pass
