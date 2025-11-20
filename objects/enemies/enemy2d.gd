## Base class for all enemy types.
##
## When inheriting from this class, be sure to override `func act_async()` to develop this
## enemy's turn behavior.
class_name Enemy2D
extends GridEntity


# TODO Move some of these qualities to a shared GridActor class.
#   I'm not going to do this preemptively, but act_async() and exhaust() seem useful for
#   NPC allies and maybe even some self-acting prop objects (in the same family as Chests).
#   But maybe self-acting Chests are really NPCs anyway——I dunno.


## Whether this Enemy2D has acted this turn.
var _exhausted := false;


## Readies this enemy to act this turn.
func prepare_to_act() -> void:
  _exhausted = false;


## Returns true if this enemy has acted this turn.
func has_acted() -> bool:
  return _exhausted;


## Returns true if this enemy is capable of acting this turn.
func can_act() -> bool:
  return (
    not has_acted()
    and not tags.has('stun')
  );


## Acts out this enemy's turn.
## When the enemy is done acting, it should call `func exhaust()` to mark itself as
## removable from any list of enemies still eligible to act.
func act_async() -> void:
  exhaust();


## Marks this enemy as 'spent', having consumed its action this turn.
## This function must be called at some point during this enemy's turn, or the turn system
## may assume this enemy can act indefinitely.
func exhaust() -> void:
  _exhausted = true;
