## The global list of persistence keys
extends Node


# [FIXME] I think I can use enums to unify names in editor and in code.

@export var _bool_dictionary: Dictionary[String, bool] = {};

func get_bool(key: String) -> bool:
  return _bool_dictionary.get(key, false);

func set_bool(key: String, value: bool) -> void:
  _bool_dictionary.set(key, value);



# [TODO] Expand the persistence key system.
#
# class GlobalPersistenceKey
# extends Component
#   :Uses a key-name as-is. It's entirely up to the developer to avoid conflicts.
#   :When interacted with, loaded, or unloaded, it automatically sets/reads its own key
#   :and value into the PersistenceKey master dictionary.
#
# class LocalPersistenceKey
# extends GlobalPersistenceKey
#   :Fully self-contained. May use its own UID for uniqueness across the project.
#   :May be given a debug name as well.
#
