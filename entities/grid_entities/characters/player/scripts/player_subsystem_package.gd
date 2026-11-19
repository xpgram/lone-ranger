## A container for holding references to various player subsystem nodes.
class_name PlayerSubsystemPackage
extends Node


# [TODO] Should this be a parent node to all these systems?


@export var inventory: PlayerInventory;



@export var focus_node: FocusableControl;

@export var move_input_repeater: InputAxisRepeater;

@export var command_menu: CommandMenu;

@export var dialogue_bubble: ThoughtsDialogueBubble;

@export var field_cursor: FieldCursor;

@export var world_shader_rect: PlayerCameraViewShader;

@export var hud_shader_rect: PlayerHUDShader;

@export var screen_shader_rect: PlayerScreenSpaceShader;

@export var dialogue_context_inspection_target: NodeRetargeter;
