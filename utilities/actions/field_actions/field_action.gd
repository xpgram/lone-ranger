## An abstract class describing the interface for an action in the game field.
## This includes anything an actor, the player, an enemy, might *do* in the game.
##
## These objects are async by nature to account for animations and other effects.
##
## For actions that do not have one static `var action_time_cost`, implement:
## `func get_variable_action_time_cost()`.
## A common pattern is to return a private number that is updated with every
## `func perform_async()` call.
@abstract
class_name FieldAction
extends Resource


## The unique identifier for this FieldAction.
## Often used as a key for this FieldAction when stored in a Dictionary.
@export var action_uid: StringName;


## The name of this action. Used in menus and callouts, among other places.
## Should ideally be kept to a maximum of 10 or so characters.
@export var action_name: String;


## The type of this action. Mostly used for sorting as FieldActions are also treated like
## tradable commodities.
@export var action_type: Enums.FieldActionType;


## Provides additional information about what this action does and how it's used.
## Should ideally be kept to a maximum of one full line of text.
@export_multiline var action_description: String;


## Separate from `var action_description`, this is in-character commentary about the
## action/item in question, and is much less likely to contain explicit instructions
## about how it's used.
##
## Ex: Lund Key -> "It bears a garden pattern."
## Ex: Flame -> "It feels warm in the mind."
##
## I could expand these, as well, as your character "learns" about them, i.e., through
## use or something. Maybe "Hole" has really unfamiliar text, but after first use she
## starts commenting on how scary it is or something.
##
## One big problem:
## # TODO How do we trigger this flavor text?
## #  I don't want to give the player a "press for more info" button; feels a bit tacky.
## #  It harms the mystique a bit. But if not, then only key items have an easy (and
## #  hidden) way of triggering these investigations: they're used, but unsuccessfully.
## #  ...
## #  Maybe MC should have more commentary in general? I could live with a "talk" button
## #  you'd use on various things in the world. You could hear her thoughts on the various
## #  traps and monuments she comes across.
## #  Your menu wouldn't specifically call out that you can investigate options, but it
## #  doesn't seem to hard to discover, either; you have a dedicated "thoughts" button.
## #  Key items would still "thoughts" on fail, though, of course. Maybe as a hint, even.
@export_multiline var action_hint: String;


# TODO While accurate, this should be a dropdown of enum names.
## The Partial Time cost for this action. In addition to animations that must be sat
## through, this number will be subtracted from the player's inaction timer when used.
@export_range(0, 15, 3.75) var action_time_cost: float;


@export_group('Icons')

# TODO Support animated icons?
## @nullable A texture to represent this action, such as when collecting it from a
## treasure chest.
@export var large_icon: Texture2D;

## @nullable A small texture to represent this action in certain contexts, such as in the
## command menu.
@export var small_icon: Texture2D;


@export_group('Sort Order', 'command_menu_sort')

# TODO Should this be a dropdown, actually?
## The top-level sort order for this action in the command menu.
@export var command_menu_sort_priority: int;

## The second-level sort order for this action in the command menu.
@export var command_menu_sort_sub_priority: int;


@export_group('Limited Use')

## Which kind of limited quantity system to use.
@export var limit_type := Enums.LimitedUseType.NoLimit;

## Counts the number of times this action may still be used, sort of like an inventory.
@export var uses_remaining := 1;


# TODO Add export group 'Targeting'
# Or maybe don't. This could be specially implemented in some inheritors of FieldAction.
# - requires_targeting: bool = false    # Default AoE is 1 tile in front of you
# - minimum_range: int = 1
# - maximum_range: int = 1
# - area_of_effect_pattern: AreaOfEffectPattern Resource = 'one tile at origin'
#   - origin: Vector2
#   - map: Vector2[]
#     - type: int          # This is used by the script, maybe an enum conversion, to
#                          # determine what kind of target-square this is. So, 0 might be
#                          # 'move self', 1 might be 'damages inhabitant', 2 might be
#                          # 'pushes target up', 3 might be 'pushes target down', etc.
# - rotatable_hint: bool = false    # Whether rotating the area_pattern does anything


## For actions that have more than one possible action time cost, this will return the
## time cost decided by the most recent call to `func perform_async()`.
## **Note:** This means you *must* call `func perform_async()` first to get an accurate
## result from this method.
func get_variable_action_time_cost() -> float:
  return action_time_cost;


## Given a performing actor and a cast-to position, returns True if this action can be
## successfully performed. Useful for doing preflight checks that may end up diverting
## input into other actions, such as how a Move input can also trigger a Spin or a Push.
@abstract func can_perform(playbill: FieldActionPlaybill) -> bool;


## Given a performing actor and a cast-to position, coordinate the animation and ratify
## the effects of this action. [br]
##
## Returns a boolean indicating whether the action was successfully carried out. A result
## of false generally means the [FieldAction] had no effects on the game board and may be
## discarded.
@abstract func perform_async(playbill: FieldActionPlaybill) -> bool;
