## A base class for subprograms to the [DebugCLI] interpreter. [br]
##
## Extending this type allows for interpreter customization, enabling different
## Godot projects to use the interpreter differently.
@abstract class_name DebugCLIScript
extends Resource


## The process function for this subprogram. Called when this program is
## invoked. [br]
##
## You may assume that [param args] is an array of size at least 1.
@abstract func exec(args: Array[String]) -> DebugCLI.Error;
