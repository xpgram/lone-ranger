class_name MagicDrawPointEntity
extends Interactive2D


## The [FieldAction] item to yield to the player when the draw point is drawn. (This
## should be a spell.)
@export var magic_item: PlayerInventoryItem;

## How many uses of magic the player must have less than for this draw point to appear.
@export var trigger_amount := 3;

## Whether the draw point may be drawn from.
var _is_drawable := true;

## A reference to the particle engine.
@onready var _particles: GPUParticles2D = $GPUParticles2D;


func _ready() -> void:
  # TODO Connect to player inventory signal
  pass


## Handler for when the player inventory is updated. If [param field_action] matches the
## draw point's held magic, and the [param new_quantity] is less than the draw point's
## trigger amount, the draw point will be reactivated.
func _on_player_inventory_changed(field_action: FieldAction, new_quantity: int) -> void:
  if field_action.action_uid != magic_item.action_uid:
    return;

  if new_quantity < magic_item.quantity:
    activate();


## Shows the draw point's visuals and flags it as magic-extraction-ready.
func activate() -> void:
  _particles.emitting = true;
  _is_drawable = true;


## Hides the draw point's visuals and flags it as empty of magic.
func deactivate() -> void:
  _particles.emitting = false;
  _is_drawable = false;


## Returns true if the draw point has mana to be extracted.
func is_drawable() -> bool:
  return _is_drawable;
