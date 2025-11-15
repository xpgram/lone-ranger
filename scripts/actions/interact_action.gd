class_name Interact_FieldAction
extends FieldAction


func action_name() -> String:
  return "Interact";


func action_description() -> String:
  return "Perform context actions in the field.";


func action_time_cost() -> float:
  return PartialTime.NONE;


func can_perform(playbill: FieldActionPlaybill) -> bool:
  # TODO Get performer.facing_direction target.is_interactive, or w/e.
  return false;


func perform_async(playbill: FieldActionPlaybill) -> void:
  # TODO Get performer.facing_direction target
  #   Trigger the interaction which may be async as it manages its own animations
  #   It may also be async-but-not-awaitable as it starts a dialogue box or something
  #   Maybe it should be awaited anyway? I need to figure this out.
  #
  # In the case of a Chest:
  #   Chest is_interactive
  #   Chest has an on_interaction handler that takes over responsibility
  #   This is awaited
  #   Chest tells performer to do the item-get! pose.
  #   Time passes, it yields; this function then yields.
  #   Turn manager allows enemies to move.
  # I've never had this happen in Void Stranger, but you could open a chest, victory pose,
  # then immediately die——I really don't see why not. It makes the most sense.
  # If the game wanted to prevent this, the answer is 1. level design, and 2. the chest
  # checks for nearby enemies and says "It's not safe" or something when you try.
  #
  # In other words, even for dialogue boxes, I *think* we can commit to things only
  # happening one-at-a-time.
  # My own InactionTimer is what really throws a wrench into this, though. But just
  # pausing it should be fine. I only need to figure out when to.
  pass;
