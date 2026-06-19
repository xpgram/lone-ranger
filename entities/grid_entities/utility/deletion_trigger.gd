class_name DeletionTrigger
extends Node2D


## A list of trigger boxes that will activate this action trigger.
@export var trigger_boxes: Array[TriggerBox];

## A list of GridEntities that may activate this action trigger.
## If the list is left empty, then any GridEntity may activate it.
@export var match_trigger_entities: Array[GridEntity];

## A list of Nodes to delete when this action trigger is activated.
@export var objects_to_delete: Array[Node];


func _ready() -> void:
  for trigger_box in trigger_boxes:
    trigger_box.entered.connect(_on_trigger_box_entered);


## When any of the trigger boxes are entered, this node will delete its list of
## objects to delete, then delete itself and all its children.
func _on_trigger_box_entered(entity: GridEntity) -> void:
  if (
    not match_trigger_entities.size() == 0
    or not match_trigger_entities.has(entity)
  ):
    return;

  for object in objects_to_delete:
    if object:
      object.queue_free();

  queue_free();
