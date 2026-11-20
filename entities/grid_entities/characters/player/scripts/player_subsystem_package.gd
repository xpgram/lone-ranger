## A container for holding references to various player subsystems.
class_name PlayerSubsystemPackage
extends Node


# [TODO] Should this be a parent node to all these systems?
# [TODO] Fix public/private access.
#   For reference:
#     inventory and focus_node were public.
#     everything else was private.
#   For the record:
#     I don't like subsystem.focus_node.accept_event() all that much.
#     I need to think of alternatives first, though.


@export_group("Subsystems")

## The Inventory node. Internally manages the player's inventory.
@export var inventory: PlayerInventory;


@export_group("UI Systems")

## The Command Menu node, for interfacing with the player's inventory and abilities.
@export var command_menu: CommandMenu;

## The dialogue bubble node, for displaying conversations and other text.
@export var dialogue_bubble: ThoughtsDialogueBubble;

## The Field Cursor node, for interfacing with locations on the Grid.
@export var field_cursor: FieldCursor;


@export_group("Post-Processing")

## A shader rect for world-only effects.
@export var world_shader_rect: PlayerCameraViewShader;

## A shader rect for HUD-only effects.
@export var hud_shader_rect: PlayerHUDShader;

## A shader rect for final-render post-processing.
@export var screen_shader_rect: PlayerScreenSpaceShader;


@export_group("Utility Nodes")

## The Control node that manages input focus.
@export var focus_node: FocusableControl;

## An Input-helper node that relays move input events.
@export var move_input_repeater: InputAxisRepeater;

## A node used by a [DialogueContext] node to provide access to the object being inspected
## to the dialogue script for that Inspect action. [br]
##
## For example, if a script needs to know an Inspect-object's remaining HP, this node
## provides access to that object, and to that HP field.
@export var dialogue_context_inspection_target: NodeRetargeter;
