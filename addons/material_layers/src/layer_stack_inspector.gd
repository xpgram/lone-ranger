@tool
class_name LayerStackInspectorPlugin
extends EditorInspectorPlugin

func _can_handle(object: Object) -> bool:
	return object is LayerStack

func _parse_property(object: Object, type: Variant.Type, name: String, hint_type: PropertyHint, hint_string: String, usage_flags: int, wide: bool) -> bool:
	if not (object is LayerStack):
		return false
	if name.begins_with("shader_parameter/"):
		return true
	if name.begins_with("render_priority"):
		return true
	if name.begins_with("next_pass"):
		return true
	if name.begins_with("resource"):
		return true
	if name == "sync_uniforms":
		return true
	
	return false

func _parse_begin(object: Object) -> void:
	if not object is LayerStack:
		return
	
	var stack: LayerStack = object

	var vbox := VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var generate := Button.new()
	generate.text = "Generate"
	generate.tooltip_text = "Generate the layered material"
	generate.pressed.connect(func() -> void:
		stack.compile()
	)
	generate.custom_minimum_size = Vector2(0, 40)
	generate.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var sync_check := CheckBox.new()
	sync_check.custom_minimum_size = Vector2(0, 30)
	sync_check.text = "Sync Uniforms"
	sync_check.tooltip_text = "Disable uniform sync with the LayerGraph. Regenerating the LayerStack will overwrite any changes made to the uniforms."
	sync_check.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sync_check.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	sync_check.button_pressed = stack.sync_uniforms
	sync_check.toggled.connect(func(on: bool) -> void:
		stack.sync_uniforms = on
		if on:
			stack.sync_uniforms_from_graph()
	)

	vbox.add_child(sync_check)
	vbox.add_child(generate)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 12)
	margin.add_theme_constant_override("margin_right", 12)
	margin.add_theme_constant_override("margin_top", 12)
	margin.add_theme_constant_override("margin_bottom", 12)

	margin.add_child(vbox)
	add_custom_control(margin)


func _parse_end(object: Object) -> void:
	if not object is LayerStack:
		return

	var layer_icon := preload("res://addons/material_layers/icons/materialLayer.svg")
	var stack: LayerStack = object

	var layers_panel := VBoxContainer.new()
	layers_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	var inspector: EditorInspector
	var option_button := OptionButton.new()
	inspector = EditorInspector.new()
	inspector.size_flags_vertical = Control.SIZE_EXPAND_FILL
	inspector.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	inspector.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED

	option_button.clear()
	option_button.clip_text = true
	option_button.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	option_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	for i in stack.layers.size():
		var layer = stack.layers[i]
		var ml_name: String = layer.name
		option_button.add_icon_item(layer_icon, "Layer %d" % i + " : %s" % ml_name, i)

	option_button.item_selected.connect(func(idx: int) -> void:
		inspector.edit(stack.layers[idx])
	)

	layers_panel.add_child(option_button)
	layers_panel.add_child(inspector)

	
	add_custom_control(layers_panel)

	if not stack.layers.is_empty():
		inspector.edit(stack.layers[0])
