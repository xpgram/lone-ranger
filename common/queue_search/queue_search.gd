## @static [br]
##
## A utility class for managing the boilerplate of different search algorithms. [br]
##
## Usage example:
## [codeblock]
##  var treasure_spot: Vector2 = QueueSearch.search(
##    QueueSearch.Mode.BreadthFirst,
##    Vector2.ZERO,
##    0,
##    func (position: Vector2, distance: int):
##      # Guard prevents infinite recursion.
##      if distance > 3 or already_checked(position):
##        return QueueSearch.none();
##      # Resolve with successful search.
##      if has_treasure(position):
##        return QueueSearch.result(position);
##
##      mark_checked(position);
##
##      # Prepare new additions to the search queue.
##      var next_positions := [
##        position + Vector2.UP,
##        position + Vector2.DOWN,
##        position + Vector2.LEFT,
##        position + Vector2.RIGHT,
##      ];
##      return QueueSearch.additions(next_positions, distance + 1);
##  );
## [/codeblock]
class_name QueueSearch


## The time in milliseconds a QueueSearch may take before a performance warning is posted.
const TIME_TO_WARN_MS := 150;

## The time in milliseconds a QueueSearch maay take before an error is raised.
## This check is an important guard against infinite loops.
const TIME_TO_ERROR_MS := 500;


## Informs the order in which nodes in the search queue are selected.
enum Mode {
  ## Another name for last-in-first-out: prioritizes nodes at the end of the stack.
  DepthFirst,
  ## Another name for first-in-first-out: prioritizes nodes at the beginning of the stack.
  BreadthFirst,
}


## QueueSearch return method. [br]
##
## Use within a search callback function to return new values to append to the queue.
## [param accumulator] may optionally be used to save a sum with each new value added to
## the queue. [br]
##
## Example:
## [codeblock]
##  return QueueSearch.additions(next_positions, distance_traveled);
## [/codeblock]
static func additions(values: Array, accumulator: Variant = null) -> QueueAdditions:
  return QueueAdditions.new(values, accumulator);


## QueueSearch return method. [br]
##
## Use within a search callback function to return nothing without discontinuing the
## search. (Alias for `QueueSearch.additions([])`). [br]
##
## Example:
## [codeblock]
##  return QueueSearch.none();
## [/codeblock]
static func none() -> QueueAdditions:
  return QueueAdditions.new([]);


## QueueSearch return method. [br]
##
## Use within a search callback function to return the final result of the search. [br]
##
## Example:
## [codeblock]
##  return QueueSearch.result(treasure_position);
## [/codeblock]
static func result(value: Variant) -> QueueResult:
  return QueueResult.new(value);


## QueueSearch return method. [br]
##
## Use within a search predicate to end the search with no result.
## (Alias for `QueueSearch.result(null)`). [br]
##
## Example:
## [codeblock]
##  return QueueSearch.end();
## [/codeblock]
static func end() -> QueueResult:
  return QueueResult.new(null);


## @nullable [br]
##
## Begins a QueueSearch from the [param initial_value] and returns the result of that
## search as determined by the [param predicate]. [br]
##
## All returns from the predicate must be through a QueueSearch return method (see the
## QueueSearch doc string for an example). [br]
##
## If the search queue is emptied before resolving, the QueueSearch will resolve with a
## null value. [br]
##
## [param search_mode] The method for selecting nodes from the search queue. [br]
##
## [param initial_value] The starting value to begin the search with. [br]
##
## [param initial_accumulator] The starting value for the cumulative. If you do not need
## a cumulative to reduce with, simply pass `null`. [br]
##
## [param predicate] The evaluation function with which to conduct the search. This has
## the signature:
## [codeblock] func (value: Variant, accumulator: Variant) -> QueueSearchReturn [/codeblock]
static func search(
    search_mode: Mode,
    initial_value: Variant,
    initial_accumulator: Variant,
    predicate: Callable,
) -> Variant:
  var search_queue: Array[NodeCursor] = [NodeCursor.new(initial_value, initial_accumulator)];
  var debug_timer = TimeEnforcer.new();
  var final_result: Variant = null;

  var search_cursor := _pop_next_cursor(search_queue, search_mode);

  while true:
    # A null search_cursor indicates the queue is empty.
    if search_cursor == null:
      break;

    debug_timer.check_time();

    var callback_return: QueueSearchReturn = predicate.call(search_cursor.value, search_cursor.accumulator);

    assert((
      callback_return is QueueResult
      or callback_return is QueueAdditions
    ), "ERROR: QueueSearch predicate did not return with a QueueSearch return function (e.g. QueueSearch.additions()).");

    if callback_return is QueueResult:
      final_result = callback_return.result;
      break;

    else:
      var new_additions := callback_return as QueueAdditions;
      _append_additions_to_queue(search_queue, new_additions);

    search_cursor = _pop_next_cursor(search_queue, search_mode);

  return final_result;


## @nullable [br]
##
## Begins an async QueueSearch from the [param initial_value] and returns the result of
## that search as determined by the [param predicate]. [br]
##
## All returns from the predicate must be through a QueueSearch return method (see the
## QueueSearch doc string for an example). [br]
##
## If the search queue is emptied before resolving, the QueueSearch will resolve with a
## null value. [br]
##
## [param search_mode] The method for selecting nodes from the search queue. [br]
##
## [param initial_value] The starting value to begin the search with. [br]
##
## [param initial_accumulator] The starting value for the cumulative. If you do not need
## a cumulative to reduce with, simply pass `null`. [br]
##
## [param predicate] The evaluation function with which to conduct the search. This has
## the signature:
## [codeblock] func (value: Variant, accumulator: Variant) -> QueueSearchReturn [/codeblock]

# static func async_search(
#     initial_value: Variant,
#     initial_accumulator: Variant,
#     search_mode: Mode,
#     predicate: Callable,
# ) -> Variant:
#   # [TODO] The predicate is not awaited using this method.
#   #   Also, what does it mean to await the predicate? Is that behavior actually desired?
#   #   I believe this method was to stand in for the original's batched search method,
#   #   but without batching anything, it doesn't really translate.
#   # [TODO] Is what I want solvable by wrapping the search call in a coroutine?
#   #   I have to learn how coroutines actually work.
#   return await search(search_mode, initial_value, initial_accumulator, predicate);


## @nullable [br]
## Removes and returns the next search node from [param search_queue]. Which node is
## selected depends on the [param search_mode]. [br]
##
## [enum Mode.BreadthFirst] will retrieve the first node in the queue. [br]
## [enum Mode.DepthFirst] will retrieve the last node in the queue. [br]
static func _pop_next_cursor(search_queue: Array[NodeCursor], search_mode: Mode) -> NodeCursor:
  var cursor: NodeCursor = null;

  match search_mode:
    Mode.BreadthFirst:
      cursor = search_queue.pop_at(0);
    Mode.DepthFirst:
      cursor = search_queue.pop_at(-1);

  return cursor;


## Modifies [param search_queue] to append [NodeCursor] objects built from [param additions].
static func _append_additions_to_queue(search_queue: Array[NodeCursor], new_additions: QueueAdditions) -> void:
  var new_cursors: Array[NodeCursor];

  for value in new_additions.values:
    new_cursors.append(NodeCursor.new(value, new_additions.accumulator));

  search_queue.append_array(new_cursors);


## A struct used by QueueSearch to package the values in the queue. [br]
## Contains the current value in focus and the accumulated result of this node's search
## path.
class NodeCursor extends RefCounted:
  ## The search value currently in focus.
  var value: Variant = null;
  ## The solution value resulting from the previous call to callbackfn that appended this
  ## node to the search queue.
  var accumulator: Variant = null;

  @warning_ignore('shadowed_variable')
  func _init(cursor_node: Variant, accumulator: Variant) -> void:
    self.value = cursor_node;
    self.accumulator = accumulator;


## Abstract class used to describe a Union-type between other classes.
## This allows functions to return extensions of this class, but not other types, like
## strings, ints, etc.
@abstract class QueueSearchReturn extends RefCounted:
  pass


## When returned by a callbackfn, signals the addition of new nodes to the search queue.
class QueueAdditions extends QueueSearchReturn:
  ## Search values to append to the search queue.
  var values: Array;
  ## The solution value from this call to callbackfn that should be bound with each value
  ## in [member values] when they are selected by the queue to be in focus.
  var accumulator: Variant;

  ## [param values] Search values to append to the search queue. [br]
  ##
  ## [param accumulator] The solution value from this call to callbackfn that should be
  ## bound with each value in [param values]. [br]
  @warning_ignore('shadowed_variable')
  func _init(values: Array, accumulator: Variant = null) -> void:
    self.values = values;
    self.accumulator = accumulator;


## When returned by a callbackfn, signals the end of the [QueueSearch] operation.
class QueueResult extends QueueSearchReturn:
  ## The final result of the search.
  var result: Variant;

  ## [param result] The value to resolve the search with.
  @warning_ignore('shadowed_variable')
  func _init(result: Variant) -> void:
    self.result = result;


## A timer class built to handle debug timers for QueueSearch.
## Pushes warnings and errors to the Godot console when certain limits have elapsed.
class TimeEnforcer extends RefCounted:
  var _start_timestamp := _get_timestamp();
  var _warning_was_posted := false;

  ## Compares the current time to [param start_timestamp] and either pushes a warning
  ## or halts the program if the elapsed time has exceeded debug limits.
  func check_time() -> void:
    var elapsed_time := _get_timestamp() - _start_timestamp;

    if not _warning_was_posted and elapsed_time >= TIME_TO_WARN_MS:
      push_warning('QueueSearch: search time has elapsed the warning time limit (%s ms).' % TIME_TO_WARN_MS);
      _warning_was_posted = true;

    if elapsed_time >= TIME_TO_ERROR_MS:
      assert(false, 'QueueSearch: search time has elapsed the error time limit (%s ms).' % TIME_TO_ERROR_MS);

  ## Returns the current time as a comparable int.
  func _get_timestamp() -> int:
    return Time.get_ticks_msec();
