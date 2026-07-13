## A base class for subprograms to the [DebugCLI] interpreter. [br]
##
## Extending this type allows for interpreter customization, enabling different
## Godot projects to use the interpreter differently.
@abstract class_name DebugCLIScript
extends RefCounted


# [TODO] Load CLIScripts into a dictionary in DebugCLI: key(program_name) -> script(this)
#   This isn't viable unless I turn DebugCLI into an autoloaded .tscn, I think.
# [TODO] get_program_name() isn't necessary if the DebugCLI.tscn names these programs
#   with dictionary keys.
#   Alternatively... if DebugCLI new where to look, it could load these debug scripts
#   automatically from a directory full of them?
#
#   Any solution that involves a specific directory path, or a collection of UIDs, or
#   a single .tres that contains the dictionary; these all require that the DebugCLI
#   is not a static library. This is annoying, but I guess it's fair. I just need to
#   think on what I want for a bit.


## The name of this subprogram. It is recommended that this be a single word, or
## a collection of words connected by hyphens, underscores.
@abstract func get_program_name() -> String;

## The process function for this subprogram. Called when this program is
## invoked.
@abstract func exec(args: Array[String]) -> void;
