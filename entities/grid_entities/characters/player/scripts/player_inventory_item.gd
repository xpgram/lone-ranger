## A [Resource] to bundle a [FieldAction] with inventory metadata.
class_name PlayerInventoryItem
extends Resource


## The action this inventory item represents in the inventory.
@export var action: FieldAction;

## Counts the number of times this action may still be used.
@export var uses_remaining := 1;
