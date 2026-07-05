## The global list of persistence keys
extends Node


## The global repository that contains all persistence keys and values.
@export var _dictionary: Dictionary[StringName, Variant] = {};


## Writes a [param value] to the persistence dictionary under [param key].
func write(key: StringName, value: Variant) -> void:
  _dictionary.set(key, value);


## Returns a value from the persistence dictionary under [param key]. If no key
## exists, returns [param default] instead.
func read(key: StringName, default: Variant = null) -> Variant:
  return _dictionary.get(key, default);


## Writes a bool [param value] to the persistence dictionary under [param key].
func write_bool(key: StringName, value: bool) -> void:
  write(key, value);


## Returns a bool value from the persistence dictionary under [param key]. If no
## key exists, returns [param default] instead.
func read_bool(key: StringName, default := false) -> bool:
  return read(key, default) as bool;


## Writes an int [param value] to the persistence dictionary under [param key].
func write_int(key: StringName, value: int) -> void:
  write(key, value);


## Returns an int value from the persistence dictionary under [param key]. If no
## key exists, returns [param default] instead.
func read_int(key: StringName, default := 0) -> int:
  return read(key, default) as int;
