## The global list of persistence keys
extends Node


@export var _bool_dictionary: Dictionary[String, bool] = {};


##
func get_bool(key: String) -> bool:
  return _bool_dictionary.get(key, false);


##
func set_bool(key: String, value: bool) -> void:
  _bool_dictionary.set(key, value);
