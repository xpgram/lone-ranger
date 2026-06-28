## A floor-button entity that is depressed when something heavy is placed over the same
## [Grid] tile. Emits signals when it is pressed and released.
class_name ButtonEntity
extends Interactive2D


# [TODO] Button is missing sound effects.


## Emitted when the button is pressed by some heavy object.
signal pressed();

## Emitted when all heavy objects leave the button's [Grid] location and it is no longer
## being held down.
signal released();


## Whether the button is currently being pressed down.
var _is_pressed := false;


@onready var _sprite := %MultiSprite2D as MultiSprite2D;


func _bind_stimulus_callbacks() -> void:
  super._bind_stimulus_callbacks();
  _stimulus_event_map.add_events({
    Stimulus.object_collision: _on_object_collision,
    Stimulus.object_separation: _on_object_separation,
  });


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
  if not _is_pressed:
    return;

  _is_pressed = false;
  _sprite.texture_key = 'neutral';
  released.emit();
