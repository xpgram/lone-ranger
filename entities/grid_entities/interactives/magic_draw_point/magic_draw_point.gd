class_name MagicDrawPointEntity
extends Interactive2D


## The [FieldAction] item to yield to the player when the draw point is drawn. (This
## should be a spell.)
@export var magic_item: PlayerInventoryItem;

## How many uses of magic the player must have [b]less than or equal to[/b] for this draw
## point to appear.
@export var activation_amount := 2;

## How many uses of magic the player must have [b]more than[/b] for this draw point to
## disappear. [br]
##
## If negative, this will be treated as equal to [member activation_amount].
@export var deactivation_amount := -1;

## Whether the draw point may be drawn from.
var _is_drawable := true;

## A reference to the particle engine.
@onready var _particles: GPUParticles2D = $GPUParticles2D;


func _ready() -> void:
  Events.player_inventory_item_updated.connect(_on_player_inventory_item_updated);


## Handler for when the player inventory is updated. If [param field_action] matches the
## draw point's held magic, and the [param new_quantity] is less than the draw point's
## trigger amount, the draw point will be reactivated.
func _on_player_inventory_item_updated(field_action: FieldAction, new_quantity: int) -> void:
  if field_action.action_uid != magic_item.action.action_uid:
    return;

  var to_activate := activation_amount;
  var to_deactivate := deactivation_amount if deactivation_amount >= 0 else activation_amount;

  if new_quantity <= to_activate:
    activate();
  elif new_quantity > to_deactivate:
    deactivate();


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
