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
  var dialogue_scene := inspect_entity.get_inspect_dialogue();

  # Find a useful default message.
  if not dialogue_scene:
    # [TODO] Pick a good default should a message not be found.
    #    (Though, can_perform ought to block those occurrences, anyway.)
    var first_letter := String(inspect_entity.name)[0].to_lower();
    var first_vowel: bool = first_letter in "aeiou";
    var name_article := 'an' if first_vowel else 'a';

    var lines := [
      "I see something.[wait=0.4][br]",
      "It's %s %s." % [name_article, inspect_entity.name],
    ];

    dialogue_scene = InspectObject_DialogueScene.new();

    var dialogue_string := " ".join(lines);
    dialogue_scene.dialogue_resource = DialogueManager.create_resource_from_text(dialogue_string);
    dialogue_scene.inspection_subject = inspect_entity;

  player.start_inspect_dialogue(dialogue_scene);

  return true;
