@tool
class_name PersistenceKeyTriggerBox
extends TriggerBox


## The persistence key to set.
@export var _persistence_key: String;

## The entities to watch for. When any of these enter this trigger box,
## the persistence key will be set to true.
@export var _matched_entities: Array[GridEntity];

## Whether to match the player entity.
@export var _match_player_entity := false;


func _ready() -> void:
  super._ready();
  entered.connect(_on_entered);


func _on_entered(entity: GridEntity) -> void:
  if (
    _matched_entities.has(entity)
    or _match_player_entity and entity is Player2D
  ):
    PersistenceKey.set_bool(_persistence_key, true);
