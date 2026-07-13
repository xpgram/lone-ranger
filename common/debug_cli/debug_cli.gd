## class_name DebugCLI [br]
##
## The command-line interpreter for testing and debugging purposes.
extends Node


enum Error {
  OK,
  NO_INPUT,
  COULD_NOT_PROCESS_LINE,
}


## The processor used to process input.
@export var _processor: DebugCLIScript;


## Engages the interpreter for a line of user input.
func process(input: String) -> DebugCLI.Error:
  History.append(input);
  var args := input.split(' ');

  if args.size() == 0:
    return Error.NO_INPUT;

  return _processor.exec(args);



## A static class to manage the CLI record of previously issued commands.
class History:
  const MAX_HISTORY := 20;

  ## The list of all recorded input lines. [br]
  ## This list is in FIFO order, so element `[lb]0]` is the oldest line in the
  ## history, while the last one at `[lb].size() - 1]` is the newest.
  static var _lines := [] as Array[String];

  ## The access-index of the historical record. Is clamped between 0 and the
  ## size of the current record.
  static var cursor := 0:
    set(value):
      cursor = clampi(value, 0, _lines.size());


  ## Sets the cursor to its default position of 0.
  static func reset_cursor() -> void:
    cursor = 0;


  ## Add a [param line] to the input history while enforcing the maximum history
  ## length.
  static func append(line: String) -> void:
    var is_command_recast: bool = (_lines.size() > 0 and _lines.back() == line);
    var is_blank_line: bool = (line.strip_edges() == "");

    if is_command_recast or is_blank_line:
      return;

    _lines.append(line);
    if _lines.size() > MAX_HISTORY:
      _lines.pop_front();


  ## Returns the input history line at the index of the history cursor. Returns
  ## and empty String if the cursor position is 0.
  static func get_cursor_line() -> String:
    var newest_to_oldest_cursor := _lines.size() - cursor;
    return (
      "" if newest_to_oldest_cursor == _lines.size()
      else _lines.get(newest_to_oldest_cursor)
    );
