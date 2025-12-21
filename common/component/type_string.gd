## A utility class for retrieving class or type strings from values, particularly from
## class references, which Godot lacks a convenient method for converting to string. [br]
##
## Usage:
##
## [codeblock]
## TypeString.from(TypeString)        # Returns 'TypeString'
## TypeString.from(TypeString.new())  # Returns 'TypeString'
## TypeString.from(10)                # Returns 'int'
## TypeString.from(2.5)               # Returns 'float'
## TypeString.from(Vector2.DOWN)      # Returns 'Vector2'
## TypeString.from('hello')           # Returns 'String'
## TypeString.from(&'hello')          # Returns 'StringName'
## [/codeblock]
class_name TypeString


## Returns the human-readable name for the given [param type].
## This works with objects, class references, and primitives.
static func from(value: Variant) -> StringName:
  var class_string: StringName;

  match typeof(value):
    TYPE_OBJECT:
      if value is Script:
        # Class reference
        class_string = _get_script_name(value);
      else:
        # Instance of class
        class_string = _get_script_name(value.get_script());
    _:
      # Some primitive type
      class_string = type_string(typeof(value));

  return class_string


## Returns the global name for [param script], or the name of its inherited [Script] if it
## does not have one. [br]
##
## It is assumed that a nameless [Script] cannot inherit from a nameless [Script].
static func _get_script_name(script: Script) -> StringName:
  var script_name := script.get_global_name();

  if script_name == '':
    script_name = script.get_base_script().get_global_name();

  return script_name;
