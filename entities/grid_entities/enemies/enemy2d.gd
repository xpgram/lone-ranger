## Base class for all enemy types.
class_name Enemy2D
extends GridEntity


# FIXME I should just use Area2D's for this. They're better.
var _is_near_player := false;


func _init() -> void:
  add_to_group(Group.Enemy);


func _ready() -> void:
  super._ready();
  _bind_health_listeners();


func _exit_tree() -> void:
  super._exit_tree();

  if _is_near_player:
    Events.enemy_disappeared.emit();


## Binds signal listeners to signals.
func _bind_health_listeners() -> void:
  var health_component := Component.get_component(self, HealthComponent) as HealthComponent;
  if health_component:
    health_component.empty.connect(_on_health_empty);


## Handler for when the [Enemy2D]'s HP meter (if it has one) drops to zero. [br]
##
## If overriding, note that this function normally calls [code]queue_free()[/code].
func _on_health_empty() -> void:
  queue_free();


func _process(_delta: float) -> void:
  # FIXME Get this out of the process step.
  var player := ActionUtils.get_player_entity();

  var distance_vector := (player.grid_position - grid_position).abs();
  var distance := distance_vector.x + distance_vector.y;

  var distance_limit := 2;

  if (
      not _is_near_player
      and distance <= distance_limit
  ):
    _is_near_player = true;
    Events.enemy_appeared.emit();
  
  if (
      _is_near_player
      and distance > distance_limit
  ):
    _is_near_player = false;
    Events.enemy_disappeared.emit();
