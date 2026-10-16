## Contains [code]SurfaceMaterial[/code] & mask texture or [code]MaskMaterial[/code].
## [url=https://www.foyez.es/docs/material-layers]Learn more[/url]
@icon ("res://addons/material_layers/icons/materialLayer.svg")
@tool
class_name MaterialLayer
extends Resource

var _setting_layer_mat := false
var _setting_mask := false
@export_storage var layer_index := 0

## Controls whether the layer is active.
@export var active: bool = true:
	set(val):
		active = val
		emit_changed()

## Name of the layer. Set automatically from LayerNodes.
@export var name: String = "Layer":
	set(val):
		name = val

## Main material for this layer. Set automatically from LayerNodes.
@export var layer_material: ShaderMaterial:
	set(val):
		if _setting_layer_mat:
			layer_material = val
			return
		_setting_layer_mat = true
		layer_material = val.duplicate(false) if val else null
		if layer_material:
			layer_material.resource_path = ""
			layer_material.set_meta("layer_stack_owned", true)
		_setting_layer_mat = false
		notify_property_list_changed()
		emit_changed()

@export_storage var mask_active = true

## Mask material for this layer. Set automatically from LayerNodes.
@export var mask_material: ShaderMaterial:
	set(val):
		if _setting_mask:
			mask_material = val
			return
		_setting_mask = true
		mask_material = val.duplicate(false) if val else null
		if mask_material:
			mask_material.resource_path = ""
			mask_material.set_meta("layer_stack_owned", true)
		_setting_mask = false
		emit_changed()


func _validate_property(property: Dictionary) -> void:
	if property.name.begins_with("resource"):
		property.usage &= ~PROPERTY_USAGE_EDITOR

	if property.name == "layer_material" or property.name == "mask_material":
		property.usage |= PROPERTY_USAGE_READ_ONLY

	if property.name == "mask_material":
		if not mask_active or layer_index == 0:
			property.usage &= ~PROPERTY_USAGE_EDITOR

	if property.name == "layer_material":
		property.hint = PROPERTY_HINT_RESOURCE_TYPE
		property.hint_string = "SurfaceMaterial,DataMaterial,OverlayMaterial"

	if property.name == "mask_material":
		property.hint = PROPERTY_HINT_RESOURCE_TYPE
		property.hint_string = "MaskMaterial"

