## The global list of persistence keys
extends Node


# [FIXME] I think I can use enums to unify names in editor and in code.

@export var _bool_dictionary: Dictionary[String, bool] = {};

func get_bool(key: String) -> bool:
  return _bool_dictionary.get(key, false);

func set_bool(key: String, value: bool) -> void:
  _bool_dictionary.set(key, value);



@export var shove_bridge_puzzle_solved := false;

@export var shove_exit_puzzle_solved := false;

@export var west_save_idol_used := false;

@export var west_save_idol_north_puzzle_solved := false;

@export var west_save_idol_west_puzzle_solved := false;

@export var hookshot_obtained := false;
