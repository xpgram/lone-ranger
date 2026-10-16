@tool
class_name LayerGraphInspectorPlugin
extends EditorInspectorPlugin

var plugin: EditorPlugin
var panel: Control
var graph_edit: LayerGraphEdit

func _can_handle(object: Object) -> bool:
	return object is LayerGraph

func _parse_begin(object: Object) -> void:
	if not object is LayerGraph:
		return

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 12)
	margin.add_theme_constant_override("margin_right", 12)
	margin.add_theme_constant_override("margin_top", 12)
	margin.add_theme_constant_override("margin_bottom", 12)

	var graph_button := Button.new()
	graph_button.text = "Open Graph"
	graph_button.custom_minimum_size = Vector2(0, 40)
	graph_button.pressed.connect(func() -> void:
		if plugin and panel and object is LayerGraph:
			plugin.make_bottom_panel_item_visible(panel)
			graph_edit.open_graph(object))

	margin.add_child(graph_button)
	add_custom_control(margin)
