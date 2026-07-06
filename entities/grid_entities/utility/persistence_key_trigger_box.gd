@tool
class_name PersistenceKeyTriggerBox
extends TriggerBox


## The `bool` persistence key to set to `true` when the collision conditions
## have been met.
@export var _persistence_key: PersistenceKey;

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
    _persistence_key.write(true);
