## The global debug event bus.
extends Node


@warning_ignore_start('unused_signal')


signal give_player_equipment(equipment: String);

signal give_player_inventory_item(item: PlayerInventoryItem);
