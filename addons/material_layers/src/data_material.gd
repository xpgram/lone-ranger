## Material used to blend [code]SurfaceMaterials[/code].
## [url=https://www.foyez.es/docs/material-layers]Learn more[/url]
@icon ("res://addons/material_layers/icons/dataMaterial.svg")
@tool
class_name DataMaterial
extends ShaderMaterial

const DEFAULT_SHADER_PATH := "res://addons/material_layers/shaders/data_shader.gdshader"

func _init() -> void:
	if resource_name.is_empty():
		resource_name = "data_material"
	if not shader:
		shader = Shader.new()
		shader.resource_name = "data_material"
		var template := load(DEFAULT_SHADER_PATH) as Shader
		if template:
			shader.code = template.code

func _validate_property(property: Dictionary) -> void:
	if property.name.begins_with("resource"):
		property.usage &= ~PROPERTY_USAGE_EDITOR
	if property.name.begins_with("layer_stack"):
		property.usage &= ~PROPERTY_USAGE_EDITOR
	if property.name == "shader" and get_meta("layer_stack_owned", false):
		property.usage &= ~PROPERTY_USAGE_EDITOR
	if property.name in ["render_priority", "next_pass"]:
		property.usage &= ~PROPERTY_USAGE_EDITOR

func _set(property: StringName, value: Variant) -> bool:
	if str(property).begins_with("shader_parameter/"):
		call_deferred("emit_changed")
	return false