## An abstract class describing the interface for an action in the game field.
## This includes anything an actor, the player, an enemy, might *do* in the game.
##
## These objects are async by nature to account for animations and other effects.
@abstract
class_name FieldAction
extends Resource


## Returns the name for this action.
@abstract func action_name() -> String;


## Returns a description of this action's effects.
@abstract func action_description() -> String;


## Returns the Partial Time cost for this action.
@abstract func action_time_cost() -> float;


## Given a performing actor and a cast-to position, returns True if this action can be
## successfully performed. Useful for doing preflight checks that may end up diverting
## input into other actions, such as how a Move input can also trigger a Spin or a Push.
@abstract func can_perform(playbill: FieldActionPlaybill) -> bool;


## Given a performing actor and a cast-to position, coordinate the animation and ratify
## the effects of this action.
@abstract func perform_async(playbill: FieldActionPlaybill) -> void;
