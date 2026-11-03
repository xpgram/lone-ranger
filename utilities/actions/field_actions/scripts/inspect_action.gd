class_name Inspect_FieldAction
extends FieldAction


func can_perform(playbill: FieldActionPlaybill) -> bool:
  var entities := Grid.get_entities(playbill.performer.faced_position);
  return entities.size() > 0;


func perform_async(playbill: FieldActionPlaybill) -> bool:
  if playbill.performer is not Player2D:
    return false;

  var player: Player2D = playbill.performer;
  var interact_position := playbill.performer.faced_position;
  var entities := Grid.get_entities(interact_position);
  var entity := entities[0];

  # [TODO] Get message text from any object found which has one.
  # [TODO] Pick a good default should a message not be found.
  #    (Though, can_perform ought to block those occurrences, anyway.)

  var first_letter := String(entity.name)[0].to_lower();
  var first_vowel: bool = first_letter in "aeiou";
  var name_article := 'an' if first_vowel else 'a';

  var message_lines := [
    "I see something.[wait=0.5][br]",
    "It's %s %s." % [name_article, entity.name],
  ];
  var message := " ".join(message_lines);
  var dialogue := DialogueManager.create_resource_from_text(message);
  player.start_dialogue(dialogue);

  return true;
