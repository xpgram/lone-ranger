## A alternative error handling method that puts exceptions into the return
## type, encouraging developers to deal with them. [br]
##
## Usage:
## [codeblock]
##  func get_file(filename: String) -> Expected:
##    # ...
##  var exp_file := get_file('.../file/path');
##  if exp_file.succeeded:
##    var file: File = exp_file._value;
##    # ...
##  else:
##    push_error('Problem reading file: ', exp_file.reason);
## [/codeblock]
##
## Note that Godot does not have a type-templating system, so returning
## [Expected] cannot accomodate arbitrary classes.
class_name Expected
extends RefCounted


## Return a successful [Expected] object with the expected [param _value].
@warning_ignore("shadowed_variable")
static func expected(value: Variant) -> Expected:
  var expected_value := Expected.new();
  expected_value.succeeded = true;
  expected_value._value = value;
  return expected_value;


## Return a failed [Expected] object with a provided [param reason].
@warning_ignore("shadowed_variable")
static func unexpected(reason: String) -> Expected:
  var unexpected_issue := Expected.new();
  unexpected_issue.succeeded = false;
  unexpected_issue.reason = reason;
  return unexpected_issue;


## Whether [member _value] succeeded in being filled. If it could not be,
## [member _value] will be null and [member reason] should have an error message.
var succeeded: bool;

## The reason given for an unexpected failure; an error message.
var reason: String;

## The expected _value, if succeeded.
var _value: Variant;


## Returns the value that this [Expected] object resolved with. Returns `false`
## if [member succeeded] is `false`.
func get_value():
  return _value;
