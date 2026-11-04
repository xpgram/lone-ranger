## A package containing resources for an inspect object scene.
class_name InspectObject_DialogueScene
extends RefCounted


## The dialogue script to play for this scene.
var dialogue_resource: DialogueResource;

## The dialogue context for the object being inspected.
var inspection_subject: GridEntity;

## Additional dialogue context objects to include when running the dialogue script.
var extra_game_states: Array[Object] = [];
