## The main [DebugCLI] processor for this project.
class_name LoneRangerCLIProcessor
extends DebugCLIScript


var _subprograms: Dictionary[String, Callable] = {
  'give': _cmd_give,
};


func exec(args: Array[String]) -> DebugCLI.Error:
  var program: Callable = _subprograms.get(args[0]);
  
  if not program:
    return DebugCLI.Error.COULD_NOT_PROCESS_LINE;

  args.pop_front();
  return program.call(args);


## A program to give the player things, such as equipment, magic, items,
## key-items etc.
func _cmd_give(args: Array[String]) -> DebugCLI.Error:
  return DebugCLI.Error.OK;
