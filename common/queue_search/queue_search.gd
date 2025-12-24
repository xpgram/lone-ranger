## @static [br]
## A
class_name QueueSearch


##
const TIME_TO_ERROR_MS := 1_000;


## 
enum SearchMode {
  ## Another name for last-in-first-out: prioritizes nodes at the end of the stack.
  DepthFirst,
  ## Another name for first-in-first-out: prioritizes nodes at the beginning of the stack.
  BreadthFirst,
}


##
static func search(
    ##
    search_mode: SearchMode,
    ##
    first_node: Variant,
    ##
    handle_node: Callable,
) -> Variant:
  var node_queue: Array[NodeCursor] = [NodeCursor.new(first_node, null)];
  var start_timestamp = _get_timestamp();
  var final_result: Variant;

  var node_cursor := NodeCursor.new(
    _pop_next_node(node_queue, search_mode),
    null,
  );

  # TODO Debug safety: time tracking
  while true:
    var handler_result: NodeHandlerReturn = handle_node.call(node_cursor);

    if handler_result is QueueResult:
      final_result = handler_result.result;
      break;

    # Setup for next iteration of the loop.
    var additions := handler_result as QueueAdditions;
    var new_cursors: Array[NodeCursor];

    for node in additions.queue_additions:
      new_cursors.append(NodeCursor.new(node, additions.result));
    node_queue.append(new_cursors);

    node_cursor = _pop_next_node(node_queue, search_mode);

  return final_result;


##
static func search_async() -> void:
  # IMPLEMENT This returns a promise that can be awaited. Maybe it shouldn't be called async, then.
  pass


## @nullable [br]
static func _pop_next_node(node_queue: Array[NodeCursor], search_mode: SearchMode) -> NodeCursor:
  var node: NodeCursor = null;

  match search_mode:
    SearchMode.BreadthFirst:
      node = node_queue.pop_at(0);
    SearchMode.DepthFirst:
      node = node_queue.pop_at(-1);

  return node;


##
static func _get_timestamp() -> int:
  return Time.get_ticks_msec();


##
class NodeCursor:
  var node: Variant = null;
  var result: Variant = null;

  @warning_ignore('shadowed_variable')
  func _init(cursor_node: Variant, result: Variant) -> void:
    self.node = cursor_node;
    self.result = result;


##
@abstract class NodeHandlerReturn:
  ## Whether this NodeHandlerReturn is a solution to the search algorithm. [br]
  ## Setting this to true will short-circuit the remaining node queue and return
  ## [member result] as the [QueueSearch]'s final result.
  var is_solution := false;


## When returned by a node handler function, signals the addition of new nodes to the
## search queue.
class QueueAdditions extends NodeHandlerReturn:
  var queue_additions: Array;
  var result: Variant;

  @warning_ignore('shadowed_variable')
  func _init(
    queue_additions: Array,
    result: Variant = null,
  ) -> void:
    self.queue_additions = queue_additions;
    self.result = result;


## When returned by a node handler function, signals the end of the [QueueSearch] operation.
class QueueResult extends NodeHandlerReturn:
  var result: Variant;

  @warning_ignore('shadowed_variable')
  func _init(
    result: Variant,
  ) -> void:
    self.result = result;
