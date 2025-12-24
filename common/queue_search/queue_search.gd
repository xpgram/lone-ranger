## @static [br]
##
class_name QueueSearch


## The time in milliseconds a QueueSearch may take before a performance warning is posted.
const TIME_TO_WARN_MS := 150;

## The time in milliseconds a QueueSearch maay take before an error is raised.
## This check is an important guard against infinite loops.
const TIME_TO_ERROR_MS := 500;


## Informs the order in which nodes in the search queue are selected.
enum SearchMode {
  ## Another name for last-in-first-out: prioritizes nodes at the end of the stack.
  DepthFirst,
  ## Another name for first-in-first-out: prioritizes nodes at the beginning of the stack.
  BreadthFirst,
}


## @nullable [br]
## Begins a QueueSearch from the [param initial_value] and returns the result of that
## search as determined by [param callbackfn]. [br]
##
## The values given to QueueSearch are wrapped into "search node" structs, that are then
## provided to the [param callbackfn]. The [param callbackfn], via its function return,
## determines from the current search node which new values should be added to the search
## queue. You may think of this as a [b]recursive algorithm.[b] [br]
##
## If the search queue is emptied, the QueueSearch will resolve with a null value. [br]
##
## [rule]
##
## [param initial_value] The starting value to begin the search with.
##
## [param search_mode] The method for selecting nodes from the search queue.
##
## [param callbackfn] has the signature:
## [codeblock] callable(cursor: NodeCursor) -> QueueAdditions | QueueResult [/codeblock]
##
## [QueueSearch.QueueAdditions] should be returned if the result of this callbackfn is to
## append new search nodes to the search queue. [br]
##
## [QueueSearch.QueueResult] should be returned when a solution to the search has been
## found and this search may be resolved with the provided result. [br]
static func search(initial_value: Variant, search_mode: SearchMode, callbackfn: Callable) -> Variant:
  var search_queue: Array[NodeCursor] = [NodeCursor.new(initial_value, null)];
  var debug_timer = TimeEnforcer.new();
  var final_result: Variant = null;

  var search_cursor := _pop_next_cursor(search_queue, search_mode);

  while true:
    # A null search_cursor indicates the queue is empty.
    if search_cursor == null:
      break;

    debug_timer.check_time();

    var callback_return: CallbackReturn = callbackfn.call(search_cursor);

    if callback_return is QueueResult:
      final_result = callback_return.result;
      break;

    else:
      var additions := callback_return as QueueAdditions;
      _append_additions_to_queue(search_queue, additions);
      search_cursor = _pop_next_cursor(search_queue, search_mode);

  return final_result;


## Begins an async QueueSearch from the [param initial_value] and returns a [Promise] for
## the result of that search as determined by [param callbackfn]. [br]
##
## The values given to QueueSearch are wrapped into "search node" structs, that are then
## provided to the [param callbackfn]. The [param callbackfn], via its function return,
## determines from the current search node which new values should be added to the search
## queue. You may think of this as a [b]recursive algorithm.[b] [br]
##
## If the search queue is emptied, the QueueSearch will resolve with a null value. [br]
##
## [param initial_value] The starting value to begin the search with.
##
## [param search_mode] The method for selecting nodes from the search queue.
##
## [param callbackfn] has the signature:
## [codeblock] callable(cursor: NodeCursor) -> QueueAdditions | QueueResult [/codeblock]
##
## [QueueSearch.QueueAdditions] should be returned if the result of this callbackfn is to
## append new search nodes to the search queue. [br]
##
## [QueueSearch.QueueResult] should be returned when a solution to the search has been
## found and this search may be resolved with the provided result. [br]
static func get_search_promise(initial_value: Variant, search_mode: SearchMode, callbackfn: Callable) -> Promise:
  return Promise.new(func (): return await search(initial_value, search_mode, callbackfn));


## @nullable [br]
## Removes and returns the next search node from [param search_queue]. Which node is
## selected depends on the [param search_mode]. [br]
##
## [enum SearchMode.BreadthFirst] will retrieve the first node in the queue. [br]
## [enum SearchMode.DepthFirst] will retrieve the last node in the queue. [br]
static func _pop_next_cursor(search_queue: Array[NodeCursor], search_mode: SearchMode) -> NodeCursor:
  var cursor: NodeCursor = null;

  match search_mode:
    SearchMode.BreadthFirst:
      cursor = search_queue.pop_at(0);
    SearchMode.DepthFirst:
      cursor = search_queue.pop_at(-1);

  return cursor;


## Modifies [param search_queue] to append [NodeCursor] objects built from [param additions].
static func _append_additions_to_queue(search_queue: Array[NodeCursor], additions: QueueAdditions) -> void:
  var new_cursors: Array[NodeCursor];

  for value in additions.values:
    new_cursors.append(NodeCursor.new(value, additions.accumulator));
  
  search_queue.append_array(new_cursors);


## A struct provided by QueueSearch to the callbackfn. [br]
## Contains the current node in focus and the accumulated result of this node's search
## path.
class NodeCursor:
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
@abstract class CallbackReturn:
  pass


## When returned by a callbackfn, signals the addition of new nodes to the search queue.
class QueueAdditions extends CallbackReturn:
  ## Search values to append to the search queue.
  var values: Array;
  ## The solution value from this call to callbackfn that should be bound with each value
  ## in [member values] when they are selected by the queue to be in focus.
  var accumulator: Variant;

  ##
  @warning_ignore('shadowed_variable')
  func _init(
      nodes: Array,
      accumulator: Variant = null,
  ) -> void:
    self.values = nodes;
    self.accumulator = accumulator;


## When returned by a callbackfn, signals the end of the [QueueSearch] operation.
class QueueResult extends CallbackReturn:
  ## The final result of the search.
  var result: Variant;

  ##
  @warning_ignore('shadowed_variable')
  func _init(
    result: Variant,
  ) -> void:
    self.result = result;


## A timer class built to handle debug timers for QueueSearch.
## Pushes warnings and errors to the Godot console when certain limits have elapsed.
class TimeEnforcer:
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
