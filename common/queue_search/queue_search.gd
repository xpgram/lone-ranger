## @static [br]
##
class_name QueueSearch


##
const TIME_TO_WARN_MS := 200;

##
const TIME_TO_ERROR_MS := 1_000;


## 
enum SearchMode {
  ## Another name for last-in-first-out: prioritizes nodes at the end of the stack.
  DepthFirst,
  ## Another name for first-in-first-out: prioritizes nodes at the beginning of the stack.
  BreadthFirst,
}


## @nullable [br]
##
## Begins a QueueSearch from the initial value [param first_node] and returns the result
## of that search as determined by [param callbackfn]. [br]
##
## "Nodes" are values of any type that are wrapped by QueueSearch into structs and then
## provided to the [param callbackfn]. The [param callbackfn], via its function return,
## determines from the current node value which new values should be added to the search
## queue. You may think of this as a [b]recursive algorithm.[/b] [br]
##
## If the search queue is emptied, the QueueSearch will resolve with a null value. [br]
##
## [param search_mode] Describes the method to select nodes from the search queue.
## See [enum QueueSearch.SearchMode] for details. [br]
##
## [param callbackfn] has the signature:
## [codeblock] callable(cursor: NodeCursor) -> QueueAdditions | QueueResult [/codeblock]
##
## [QueueSearch.QueueAdditions] should be returned if the result of this callbackfn is to append
## new search nodes to the search queue. [br]
##
## [QueueSearch.QueueResult] should be returned when a solution to the search has been found and
## this search may be resolved with the provided result. [br]
static func search(first_node: Variant, search_mode: SearchMode, callbackfn: Callable) -> Variant:
  var node_queue: Array[NodeCursor] = [NodeCursor.new(first_node, null)];
  var debug_timer = TimeEnforcer.new();
  var final_result: Variant = null;

  var node_cursor := _pop_next_node(node_queue, search_mode);

  while true:
    # A null node_cursor indicates the queue is empty.
    if node_cursor == null:
      break;

    debug_timer.check_time();

    var callback_result: CallbackReturn = callbackfn.call(node_cursor);

    if callback_result is QueueResult:
      final_result = callback_result.result;
      break;

    else:
      var additions := callback_result as QueueAdditions;
      _append_additions_to_queue(node_queue, additions);
      node_cursor = _pop_next_node(node_queue, search_mode);

  return final_result;


##
static func search_async() -> void:
  # IMPLEMENT This returns a promise that can be awaited. Maybe it shouldn't be called async, then.
  pass


## @nullable [br]
## Removes and returns the next search node from [param node_queue]. Which node is
## selected depends on the [param search_mode]. [br]
##
## [enum SearchMode.BreadthFirst] will retrieve the first node in the queue. [br]
## [enum SearchMode.DepthFirst] will retrieve the last node in the queue. [br]
static func _pop_next_node(node_queue: Array[NodeCursor], search_mode: SearchMode) -> NodeCursor:
  var node: NodeCursor = null;

  match search_mode:
    SearchMode.BreadthFirst:
      node = node_queue.pop_at(0);
    SearchMode.DepthFirst:
      node = node_queue.pop_at(-1);

  return node;


## Modifies [param node_queue] to append [NodeCursor] objects built from [param additions].
static func _append_additions_to_queue(node_queue: Array[NodeCursor], additions: QueueAdditions) -> void:
  var new_cursors: Array[NodeCursor];

  for node in additions.nodes:
    new_cursors.append(NodeCursor.new(node, additions.accumulator));
  
  node_queue.append_array(new_cursors);


## A struct provided by QueueSearch to the callbackfn. [br]
## Contains the current node in focus and the accumulated result of this node's search
## path.
class NodeCursor:
  ## The search node currently in focus.
  var node: Variant = null;
  ## The value resulting from the previous call to callbackfn that appended this node to
  ## the search queue.
  var accumulator: Variant = null;

  @warning_ignore('shadowed_variable')
  func _init(cursor_node: Variant, accumulator: Variant) -> void:
    self.node = cursor_node;
    self.accumulator = accumulator;


## Abstract class used to describe a Union-type between other classes.
## This allows functions to return extensions of this class, but not other types, like
## strings, ints, etc.
@abstract class CallbackReturn:
  pass


## When returned by a callbackfn, signals the addition of new nodes to the
## search queue.
class QueueAdditions extends CallbackReturn:
  ## Search nodes to append to the search queue.
  var nodes: Array;
  ## The result value from this call to callbackfn that should be bound to each node in
  ## [member nodes] when they are selected by the queue to be in focus.
  var accumulator: Variant;

  @warning_ignore('shadowed_variable')
  func _init(
      nodes: Array,
      accumulator: Variant = null,
  ) -> void:
    self.nodes = nodes;
    self.accumulator = accumulator;


## When returned by a callbackfn, signals the end of the [QueueSearch] operation.
class QueueResult extends CallbackReturn:
  ## The final result of the search.
  var result: Variant;

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
      push_warning('QueueSearch: search time has elapsed the warning time limit (%s).' % TIME_TO_WARN_MS);
      _warning_was_posted = true;

    if elapsed_time >= TIME_TO_ERROR_MS:
      assert(false, 'QueueSearch: search time has elapsed the error time limit (%s).' % TIME_TO_ERROR_MS);
  
  ## Returns the current time as a comparable int.
  func _get_timestamp() -> int:
    return Time.get_ticks_msec();
