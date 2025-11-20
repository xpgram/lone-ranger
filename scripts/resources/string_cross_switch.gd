class_name StringCrossSwitch
extends Resource

@export var default: StringName;
@export var up: StringName;
@export var down: StringName;
@export var left: StringName;
@export var right: StringName;


func get_value(vector: Vector2i) -> StringName:
  var value: StringName;

  match vector:
    Vector2i.UP:
      value = up;
    Vector2i.DOWN:
      value = down;
    Vector2i.LEFT:
      value = left;
    Vector2i.RIGHT:
      value = right;
  
  value = value if value != '' else default;
  return value;
