## A alternative error handling method that puts exceptions into the return
## type, encouraging developers to deal with them. [br]
##
## Usage:
## [codeblock]
##  func get_file(filename: String) -> Expected:
##    # ...
##  var exp_file := get_file('.../file/path');
##  if exp_file.succeeded:
##    var file: File = exp_file.value;
##    # ...
##  else:
##    push_error('Problem reading file: ', exp_file.reason);
## [/codeblock]
##
## Note that Godot does not have a type-templating system, so returning
## [Expected] cannot accomodate arbitrary classes.
class_name Expected
extends RefCounted


# [TODO] This is similar to [GodotPromise]; should I look there for
#   implementation tips?
# [TODO] Add ExpectedInt, ExpectedString, etc., typed extensions.
# [TODO] Add abstract ExpectedType that can be arbitrarily extended for any
#   script which really wants to use it?

# [FIXME] Add Expected[Type] template whenever Godot allows such.


## Return a successful [Expected] object with the expected [param value].
@warning_ignore("shadowed_variable")
static func expected(value: Variant) -> Expected:
  var expected_value := Expected.new();
  expected_value.succeeded = true;
  expected_value.value = value;
  return expected_value;


## Return a failed [Expected] object with a provided [param reason].
@warning_ignore("shadowed_variable")
static func unexpected(reason: String) -> Expected:
  var unexpected_issue := Expected.new();
  unexpected_issue.succeeded = false;
  unexpected_issue.reason = reason;
  return unexpected_issue;


## Whether [member value] succeeded in being filled. If it could not be,
## [member value] will be null and [member reason] should have an error message.
var succeeded: bool;

## The expected value, if succeeded.
var value: Variant;

## The reason given for an unexpected failure; an error message.
var reason: String;
