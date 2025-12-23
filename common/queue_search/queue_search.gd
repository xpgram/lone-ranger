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


## A 'deposit-box' containing the final result of the fully evaluated algorithm.
var result_node: Variant;

var search_mode: SearchMode;

var node_queue := [];

var handle_node: Callable;

var start_timestamp = Time.get_ticks_msec();

var finished := false;



# TODO Refactor this script.
#  This was adapted from QueueSearch in AW, and I think we can do better.
#  I'm not implementing staccato search right now, so this doesn't need to be a class
#  object.



func _init(
    ##
    search_mode: SearchMode,
    ##
    first_node: Variant,
    ##
    handle_node: Callable,
) -> void:
  self.search_mode = search_mode;
  self.node_queue = [first_node];
  self.handle_node = handle_node;

  while not finished:
    _handle_next_node();


##
func _handle_next_node() -> void:
  if finished:
    return;
  
  var node = _get_next_node();

  if not node:
    _end_search();
    return;
  
  var process_result = handle_node.call(node);

  if process_result == 'break':
    result_node = node;
    _end_search();

  elif process_result != null:
    if process_result is Array:
      node_queue.append_array(process_result)
    else:
      node_queue.append(process_result);


##
func _get_next_node() -> Variant:
  var node;

  if search_mode == SearchMode.BreadthFirst:
    node = node_queue.pop_at(0);
  elif search_mode == SearchMode.DepthFirst:
    node = node_queue.pop_at(-1);
  
  return node;


##
func _end_search() -> void:
  finished = true;


##
func _error_time_has_elapsed() -> bool:
  return start_timestamp - Time.get_ticks_msec() >= TIME_TO_ERROR_MS;


##
class SearchState:
  var node_queue := [];
  var result: Variant = null;
