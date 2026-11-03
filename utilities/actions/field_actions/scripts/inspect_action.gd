class_name Inspect_FieldAction
extends FieldAction


func can_perform(playbill: FieldActionPlaybill) -> bool:
  var entities := Grid.get_entities(playbill.performer.faced_position);
  return entities.any(func (entity: GridEntity): return entity.is_inspectable);


func perform_async(playbill: FieldActionPlaybill) -> bool:
  if playbill.performer is not Player2D:
    return false;

  var player: Player2D = playbill.performer;
  var interact_position := playbill.performer.faced_position;

  var entities := Grid.get_entities(interact_position);
  var inspect_idx := entities.find_custom(func (entity):
    return entity.is_inspectable;
  );

  if inspect_idx == -1:
    return true;

  var inspect_entity := entities[inspect_idx];

  var dialogue_string := inspect_entity.inspection_dialogue;

  # Find a useful default message.
  if dialogue_string == "":
    # [TODO] Pick a good default should a message not be found.
    #    (Though, can_perform ought to block those occurrences, anyway.)
    var first_letter := String(inspect_entity.name)[0].to_lower();
    var first_vowel: bool = first_letter in "aeiou";
    var name_article := 'an' if first_vowel else 'a';

    var message_lines := [
      "I see something.[wait=0.3][br]",
      "It's %s %s." % [name_article, inspect_entity.name],
    ];

    dialogue_string = " ".join(message_lines);

  var dialogue := DialogueManager.create_resource_from_text(dialogue_string);
  player.start_dialogue(dialogue);

  return true;
