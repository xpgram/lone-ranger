## A [Resource] to bundle a [FieldAction] with inventory metadata. [br]
##
## If instantiating by code, call [method fill] as the [Resource] constructor.
class_name PlayerInventoryItem
extends Resource


## The action this inventory item represents in the inventory.
@export var action: FieldAction;

## How many copies of this item that are owned.
@export var quantity := 1;


## Acts as a [Resource] constructor to be called after [method _init].
## The editor does not play nicely with Resources that override [method _init].
@warning_ignore('shadowed_variable')
func fill(action: FieldAction, quantity: int = 1) -> PlayerInventoryItem:
  self.action = action;
  self.quantity = quantity;

  return self;
