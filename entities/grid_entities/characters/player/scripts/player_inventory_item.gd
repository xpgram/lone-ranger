## A [Resource] to bundle a [FieldAction] with inventory metadata.
class_name PlayerInventoryItem
extends Resource


## The action this inventory item represents in the inventory.
@export var action: FieldAction;

## How many copies of this item that are owned.
@export var quantity := 1;
