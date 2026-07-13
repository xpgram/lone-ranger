## The global debug event bus.
extends Node


@warning_ignore_start('unused_signal')


## Gives the player an equipment item.
signal give_player_equipment(equipment: String);

## Gives the player an inventory item (magic, item, key-item, etc).
signal give_player_inventory_item(item: PlayerInventoryItem);
