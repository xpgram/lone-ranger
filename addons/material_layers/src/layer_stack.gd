## Contains [code]MaterialLayer[/code] resource and generates final material.
## [url=https://www.foyez.es/docs/material-layers]Learn more[/url]
@icon ("res://addons/material_layers/icons/layerStack.svg")
@tool
class_name LayerStack
extends ShaderMaterial

func _init() -> void:
	if resource_name.is_empty():
		resource_name = "layer_stack"
	call_deferred("_auto_compile_on_load")

var _layers_initialized := false
var _compiled := false

## [code]LayerGraph[/code] resource used to generate the final material. [url=https://www.foyez.es/docs/material-layers]Learn more[/url]
@export var layer_graph: LayerGraph:
	set(val):
		layer_graph = val
		if val and val.resource_path != "" and not val.resource_path.contains("::"):
			val.resource_name = val.resource_path.get_file()
		call_deferred("_connect_live_sync")

## When enabled, uniform values are copied from the graph's node materials into this stack.
@export var sync_uniforms: bool = true:
	set(val):
		sync_uniforms = val
		call_deferred("_connect_live_sync")

@export_storage var layers: Array[MaterialLayer] = []

var old_active : Array[bool] = []

var layer_uniform_maps: Array = []
var _assets: Array = []
var _parse_uniform_cache: Dictionary = {}

func _cached_layer_uniforms(shader: Shader, is_mask: bool, slot: int) -> Dictionary:
	var key := shader
	if _parse_uniform_cache.has(key):
		var entry: Dictionary = _parse_uniform_cache[key]
		if entry["code"] == shader.code and entry["is_mask"] == is_mask and entry["slot"] == slot:
			return entry["result"]
	var code_clean := strip_comments(shader.code)
	var result := parse_uniforms(strip_helper_funcs(code_clean), is_mask, slot)
	_parse_uniform_cache[key] = {
		"code": shader.code,
		"is_mask": is_mask,
		"slot": slot,
		"result": result,
	}
	return result

func _ensure_assets() -> Array:
	if _assets.is_empty():
		_assets = _collect_layer_assets()
	return _assets

func _invalidate_assets() -> void:
	_assets.clear()

const TYPES := ["float", "int", "bool", "bvec2", "bvec3", "bvec4", "ivec2", "ivec3", "ivec4", "uint", "uvec2", "uvec3","uvec4","vec2", "vec3", "vec4", "mat2", "mat3", "mat4", ]

const OUTPUTS := ["VERTEX", "ALBEDO", "NORMAL_MAP", "NORMAL_MAP_DEPTH", "ROUGHNESS", "AO", "AO_LIGHT_AFFECT", "EMISSION", "BENT_NORMAL", "METALLIC", "SPECULAR", "RIM", "RIM_TINT", "CLEARCOAT", "CLEARCOAT_GLOSS", "ANISOTROPY", "ANISOTROPY_FLOW", "SSS_STRENGTH", "SSS_TRANSMITTANCE_COLOR", "SSS_TRANSMITTANCE_DEPTH", "BACKLIGHT", "FOG", "RADIANCE", "IRRADIANCE"]

const DEFAULT_MAT_FRAGMENT_OUTPUT := "
	layerMatFragment DEFAULT_MAT_FRAGMENT = layerMatFragment(
		vec3(0.75),			   
		vec3(0.5, 0.5, 1.0),	  
		1.0,					  
		1.0,					  
		0.5,					  
		0.0,					  
		vec3(0.0),				
		vec3(0.5, 0.5, 1.0),	
		vec3(0.5, 0.5, 1.0),	  
		1.0,					  
		0.5,					  
		0.0,					  
		0.0				
	);
	"

const DEFAULT_MAT_VERTEX_OUTPUT := "
	layerMatVertex DEFAULT_MAT_VERTEX = layerMatVertex(
		VERTEX,
		0.5
	);
	"


const MAT_FRAGMENT_OUTPUTS := "
	ALBEDO = final_mat_fragment.layer_mat_albedo;
	NORMAL_MAP = layer_normalCombine(final_mat_fragment.layer_mat_normal_map, final_mat_fragment.layer_mat_mesh_normal_map);
	BENT_NORMAL_MAP = final_mat_fragment.layer_mat_bent_normal;
	ROUGHNESS = final_mat_fragment.layer_mat_roughness;
	AO = final_mat_fragment.layer_mat_ao * final_mat_fragment.layer_mat_mesh_ao;
	METALLIC = final_mat_fragment.layer_mat_metallic;
	EMISSION = final_mat_fragment.layer_mat_emission;
	"

const MAT_FRAGMENT_LAYER_OUT_FIELDS := {
	"LAYER_OUT_ALBEDO":	 "layer_mat_albedo",
	"LAYER_OUT_NORMAL_MAP": "layer_mat_normal_map",
	"LAYER_OUT_MESH_NORMAL_MAP": "layer_mat_mesh_normal_map",
	"LAYER_OUT_BENT_NORMAL": "layer_mat_bent_normal",
	"LAYER_OUT_ROUGHNESS":  "layer_mat_roughness",
	"LAYER_OUT_AO":		 "layer_mat_ao",
	"LAYER_OUT_HEIGHT":	 "layer_mat_height",
	"LAYER_OUT_METALLIC":   "layer_mat_metallic",
	"LAYER_OUT_EMISSION":   "layer_mat_emission",
	"LAYER_OUT_MESH_AO":	"layer_mat_mesh_ao",
	"LAYER_OUT_MESH_HEIGHT": "layer_mat_mesh_height",
	"LAYER_OUT_MESH_CURVATURE": "layer_mat_mesh_curvature",
	"LAYER_OUT_MESH_THICKNESS": "layer_mat_mesh_thickness",
}
const MAT_FRAGMENT_LAYER_BASE_FIELDS := {
	"LAYER_BASE_ALBEDO":	 "layer_mat_albedo",
	"LAYER_BASE_NORMAL_MAP": "layer_mat_normal_map",
	"LAYER_BASE_MESH_NORMAL_MAP": "layer_mat_mesh_normal_map",
	"LAYER_BASE_BENT_NORMAL": "layer_mat_bent_normal",
	"LAYER_BASE_ROUGHNESS":  "layer_mat_roughness",
	"LAYER_BASE_AO":		 "layer_mat_ao",
	"LAYER_BASE_HEIGHT":	 "layer_mat_height",
	"LAYER_BASE_METALLIC":   "layer_mat_metallic",
	"LAYER_BASE_EMISSION":   "layer_mat_emission",
	"LAYER_BASE_MESH_AO":	"layer_mat_mesh_ao",
	"LAYER_BASE_MESH_HEIGHT": "layer_mat_mesh_height",
	"LAYER_BASE_MESH_CURVATURE": "layer_mat_mesh_curvature",
	"LAYER_BASE_MESH_THICKNESS": "layer_mat_mesh_thickness",
}
const MAT_FRAGMENT_LAYER_BELOW_FIELDS := {
	"LAYER_BELOW_ALBEDO":	 "layer_mat_albedo",
	"LAYER_BELOW_NORMAL_MAP": "layer_mat_normal_map",
	"LAYER_BELOW_MESH_NORMAL_MAP": "layer_mat_mesh_normal_map",
	"LAYER_BELOW_BENT_NORMAL": "layer_mat_bent_normal",
	"LAYER_BELOW_ROUGHNESS":  "layer_mat_roughness",
	"LAYER_BELOW_AO":		 "layer_mat_ao",
	"LAYER_BELOW_HEIGHT":	 "layer_mat_height",
	"LAYER_BELOW_METALLIC":   "layer_mat_metallic",
	"LAYER_BELOW_EMISSION":   "layer_mat_emission",
	"LAYER_BELOW_MESH_AO":	"layer_mat_mesh_ao",
	"LAYER_BELOW_MESH_HEIGHT": "layer_mat_mesh_height",
	"LAYER_BELOW_MESH_CURVATURE": "layer_mat_mesh_curvature",
	"LAYER_BELOW_MESH_THICKNESS": "layer_mat_mesh_thickness",
}
const MAT_FRAGMENT_LAYER_BLEND_FIELDS := {
	"LAYER_BLEND_ALBEDO":	 "layer_mat_albedo",
	"LAYER_BLEND_NORMAL_MAP": "layer_mat_normal_map",
	"LAYER_BLEND_MESH_NORMAL_MAP": "layer_mat_mesh_normal_map",
	"LAYER_BLEND_BENT_NORMAL": "layer_mat_bent_normal",
	"LAYER_BLEND_ROUGHNESS":  "layer_mat_roughness",
	"LAYER_BLEND_AO":		 "layer_mat_ao",
	"LAYER_BLEND_HEIGHT":	 "layer_mat_height",
	"LAYER_BLEND_METALLIC":   "layer_mat_metallic",
	"LAYER_BLEND_EMISSION":   "layer_mat_emission",
	"LAYER_BLEND_MESH_AO":	"layer_mat_mesh_ao",
	"LAYER_BLEND_MESH_HEIGHT": "layer_mat_mesh_height",
	"LAYER_BLEND_MESH_CURVATURE": "layer_mat_mesh_curvature",
	"LAYER_BLEND_MESH_THICKNESS": "layer_mat_mesh_thickness",
}


const MAT_VERTEX_OUTPUTS := "
	VERTEX = final_mat_vertex.layer_mat_vertex;
	"

const MAT_VERTEX_LAYER_OUT_FIELDS := {
	"LAYER_OUT_VERTEX":	 "layer_mat_vertex",
	"LAYER_OUT_HEIGHT":	 "layer_mat_height", }

const MAT_VERTEX_LAYER_BASE_FIELDS := {
	"LAYER_BASE_VERTEX":	 "layer_mat_vertex",
	"LAYER_BASE_HEIGHT":	 "layer_mat_height", }

const MAT_VERTEX_LAYER_BELOW_FIELDS := {
	"LAYER_BELOW_VERTEX":	 "layer_mat_vertex",
	"LAYER_BELOW_HEIGHT":	 "layer_mat_height", }

const MAT_VERTEX_LAYER_BLEND_FIELDS := {
	"LAYER_BLEND_VERTEX":	 "layer_mat_vertex",
	"LAYER_BLEND_HEIGHT":	 "layer_mat_height", }

const DEFAULT_DATA_FRAGMENT_OUTPUT := "
	layerDataFragment DEFAULT_DATA_FRAGMENT = layerDataFragment(
		vec4(0.0),
		vec4(0.0),
		vec4(0.0),
		vec4(0.0),
		vec4(0.0),
		vec4(0.0),
		vec4(0.0),
		vec4(0.0),
		vec4(0.0),
		vec4(0.0),
		vec4(0.0),
		vec4(0.0),
		vec4(0.0),
		vec4(0.0),
		vec4(0.0),
		vec4(0.0),
		0.0,
		0.0,
		0.0,
		0.0,
		0.0,
		0.0,
		0.0,
		0.0,
		0.0,
		0.0,
		0.0,
		0.0,
		0.0,
		0.0,
		0.0,
		0.0
	);
	"

const DEFAULT_DATA_VERTEX_OUTPUT := "
	layerDataVertex DEFAULT_DATA_VERTEX = layerDataVertex(
		vec4(0.0),
		vec4(0.0),
		vec4(0.0),
		vec4(0.0),
		vec4(0.0),
		vec4(0.0),
		vec4(0.0),
		vec4(0.0),
		0.0,
		0.0,
		0.0,
		0.0,
		0.0,
		0.0,
		0.0,
		0.0
	);
	"


const DATA_FRAGMENT_LAYER_OUT_FIELDS := {
	"LAYER_OUT_TEX_0": "layer_data_tex_0",
	"LAYER_OUT_TEX_1": "layer_data_tex_1",
	"LAYER_OUT_TEX_2": "layer_data_tex_2",
	"LAYER_OUT_TEX_3": "layer_data_tex_3",
	"LAYER_OUT_TEX_4": "layer_data_tex_4",
	"LAYER_OUT_TEX_5": "layer_data_tex_5",
	"LAYER_OUT_TEX_6": "layer_data_tex_6",
	"LAYER_OUT_TEX_7": "layer_data_tex_7",
	"LAYER_OUT_TEX_8": "layer_data_tex_8",
	"LAYER_OUT_TEX_9": "layer_data_tex_9",
	"LAYER_OUT_TEX_10": "layer_data_tex_10",
	"LAYER_OUT_TEX_11": "layer_data_tex_11",
	"LAYER_OUT_TEX_12": "layer_data_tex_12",
	"LAYER_OUT_TEX_13": "layer_data_tex_13",
	"LAYER_OUT_TEX_14": "layer_data_tex_14",
	"LAYER_OUT_TEX_15": "layer_data_tex_15",

	"LAYER_OUT_MASK_0": "layer_data_mask_0",
	"LAYER_OUT_MASK_1": "layer_data_mask_1",
	"LAYER_OUT_MASK_2": "layer_data_mask_2",
	"LAYER_OUT_MASK_3": "layer_data_mask_3",
	"LAYER_OUT_MASK_4": "layer_data_mask_4",
	"LAYER_OUT_MASK_5": "layer_data_mask_5",
	"LAYER_OUT_MASK_6": "layer_data_mask_6",
	"LAYER_OUT_MASK_7": "layer_data_mask_7",
	"LAYER_OUT_MASK_8": "layer_data_mask_8",
	"LAYER_OUT_MASK_9": "layer_data_mask_9",
	"LAYER_OUT_MASK_10": "layer_data_mask_10",
	"LAYER_OUT_MASK_11": "layer_data_mask_11",
	"LAYER_OUT_MASK_12": "layer_data_mask_12",
	"LAYER_OUT_MASK_13": "layer_data_mask_13",
	"LAYER_OUT_MASK_14": "layer_data_mask_14",
	"LAYER_OUT_MASK_15": "layer_data_mask_15", }

const DATA_FRAGMENT_LAYER_BASE_FIELDS := {
	"LAYER_BELOW_TEX_0": "layer_data_tex_0",
	"LAYER_BELOW_TEX_1": "layer_data_tex_1",
	"LAYER_BELOW_TEX_2": "layer_data_tex_2",
	"LAYER_BELOW_TEX_3": "layer_data_tex_3",
	"LAYER_BELOW_TEX_4": "layer_data_tex_4",
	"LAYER_BELOW_TEX_5": "layer_data_tex_5",
	"LAYER_BELOW_TEX_6": "layer_data_tex_6",
	"LAYER_BELOW_TEX_7": "layer_data_tex_7",
	"LAYER_BELOW_TEX_8": "layer_data_tex_8",
	"LAYER_BELOW_TEX_9": "layer_data_tex_9",
	"LAYER_BELOW_TEX_10": "layer_data_tex_10",
	"LAYER_BELOW_TEX_11": "layer_data_tex_11",
	"LAYER_BELOW_TEX_12": "layer_data_tex_12",
	"LAYER_BELOW_TEX_13": "layer_data_tex_13",
	"LAYER_BELOW_TEX_14": "layer_data_tex_14",
	"LAYER_BELOW_TEX_15": "layer_data_tex_15",

	"LAYER_BELOW_MASK_0": "layer_data_mask_0",
	"LAYER_BELOW_MASK_1": "layer_data_mask_1",
	"LAYER_BELOW_MASK_2": "layer_data_mask_2",
	"LAYER_BELOW_MASK_3": "layer_data_mask_3",
	"LAYER_BELOW_MASK_4": "layer_data_mask_4",
	"LAYER_BELOW_MASK_5": "layer_data_mask_5",
	"LAYER_BELOW_MASK_6": "layer_data_mask_6",
	"LAYER_BELOW_MASK_7": "layer_data_mask_7",
	"LAYER_BELOW_MASK_8": "layer_data_mask_8",
	"LAYER_BELOW_MASK_9": "layer_data_mask_9",
	"LAYER_BELOW_MASK_10": "layer_data_mask_10",
	"LAYER_BELOW_MASK_11": "layer_data_mask_11",
	"LAYER_BELOW_MASK_12": "layer_data_mask_12",
	"LAYER_BELOW_MASK_13": "layer_data_mask_13",
	"LAYER_BELOW_MASK_14": "layer_data_mask_14",
	"LAYER_BELOW_MASK_15": "layer_data_mask_15", }


const DATA_VERTEX_LAYER_OUT_FIELDS := {
	"LAYER_OUT_TEX_0": "layer_data_tex_0",
	"LAYER_OUT_TEX_1": "layer_data_tex_1",
	"LAYER_OUT_TEX_2": "layer_data_tex_2",
	"LAYER_OUT_TEX_3": "layer_data_tex_3",
	"LAYER_OUT_TEX_4": "layer_data_tex_4",
	"LAYER_OUT_TEX_5": "layer_data_tex_5",
	"LAYER_OUT_TEX_6": "layer_data_tex_6",
	"LAYER_OUT_TEX_7": "layer_data_tex_7",

	"LAYER_OUT_MASK_0": "layer_data_mask_0",
	"LAYER_OUT_MASK_1": "layer_data_mask_1",
	"LAYER_OUT_MASK_2": "layer_data_mask_2",
	"LAYER_OUT_MASK_3": "layer_data_mask_3",
	"LAYER_OUT_MASK_4": "layer_data_mask_4",
	"LAYER_OUT_MASK_5": "layer_data_mask_5",
	"LAYER_OUT_MASK_6": "layer_data_mask_6",
	"LAYER_OUT_MASK_7": "layer_data_mask_7", }

const DATA_VERTEX_LAYER_BASE_FIELDS := {
	"LAYER_BELOW_TEX_0": "layer_data_tex_0",
	"LAYER_BELOW_TEX_1": "layer_data_tex_1",
	"LAYER_BELOW_TEX_2": "layer_data_tex_2",
	"LAYER_BELOW_TEX_3": "layer_data_tex_3",
	"LAYER_BELOW_TEX_4": "layer_data_tex_4",
	"LAYER_BELOW_TEX_5": "layer_data_tex_5",
	"LAYER_BELOW_TEX_6": "layer_data_tex_6",
	"LAYER_BELOW_TEX_7": "layer_data_tex_7",

	"LAYER_BELOW_MASK_0": "layer_data_mask_0",
	"LAYER_BELOW_MASK_1": "layer_data_mask_1",
	"LAYER_BELOW_MASK_2": "layer_data_mask_2",
	"LAYER_BELOW_MASK_3": "layer_data_mask_3",
	"LAYER_BELOW_MASK_4": "layer_data_mask_4",
	"LAYER_BELOW_MASK_5": "layer_data_mask_5",
	"LAYER_BELOW_MASK_6": "layer_data_mask_6",
	"LAYER_BELOW_MASK_7": "layer_data_mask_7", }


var _mat_fragment_layer_out_regex: Dictionary = {}
var _mat_fragment_layer_base_regex: Dictionary = {}
var _mat_fragment_layer_below_regex: Dictionary = {}
var _mat_fragment_layer_blend_regex: Dictionary = {}

var _mat_vertex_layer_out_regex: Dictionary = {}
var _mat_vertex_layer_base_regex: Dictionary = {}
var _mat_vertex_layer_below_regex: Dictionary = {}
var _mat_vertex_layer_blend_regex: Dictionary = {}

var _data_fragment_layer_out_regex: Dictionary = {}
var _data_fragment_layer_base_regex: Dictionary = {}

var _data_vertex_layer_out_regex: Dictionary = {}
var _data_vertex_layer_base_regex: Dictionary = {}

func _get_fragment_layer_out_regex() -> Dictionary:
	if _mat_fragment_layer_out_regex.is_empty():
		for out_name in MAT_FRAGMENT_LAYER_OUT_FIELDS:
			var rx := RegEx.new()
			rx.compile("\\b" + out_name + "\\b")
			_mat_fragment_layer_out_regex[out_name] = rx
	
	return _mat_fragment_layer_out_regex

func _get_fragment_layer_base_regex() -> Dictionary:
	if _mat_fragment_layer_base_regex.is_empty():
		for in_name in MAT_FRAGMENT_LAYER_BASE_FIELDS:
			var rx := RegEx.new()
			rx.compile("\\b" + in_name + "\\b")
			_mat_fragment_layer_base_regex[in_name] = rx
	
	return _mat_fragment_layer_base_regex

func _get_fragment_layer_below_regex() -> Dictionary:
	if _mat_fragment_layer_below_regex.is_empty():
		for in_name in MAT_FRAGMENT_LAYER_BELOW_FIELDS:
			var rx := RegEx.new()
			rx.compile("\\b" + in_name + "\\b")
			_mat_fragment_layer_below_regex[in_name] = rx
	
	return _mat_fragment_layer_below_regex

func _get_fragment_layer_blend_regex() -> Dictionary:
	if _mat_fragment_layer_blend_regex.is_empty():
		for in_name in MAT_FRAGMENT_LAYER_BLEND_FIELDS:
			var rx := RegEx.new()
			rx.compile("\\b" + in_name + "\\b")
			_mat_fragment_layer_blend_regex[in_name] = rx
	
	return _mat_fragment_layer_blend_regex

func _get_vertex_layer_out_regex() -> Dictionary:
	if _mat_vertex_layer_out_regex.is_empty():
		for out_name in MAT_VERTEX_LAYER_OUT_FIELDS:
			var rx := RegEx.new()
			rx.compile("\\b" + out_name + "\\b")
			_mat_vertex_layer_out_regex[out_name] = rx
	
	return _mat_vertex_layer_out_regex

func _get_vertex_layer_base_regex() -> Dictionary:
	if _mat_vertex_layer_base_regex.is_empty():
		for in_name in MAT_VERTEX_LAYER_BASE_FIELDS:
			var rx := RegEx.new()
			rx.compile("\\b" + in_name + "\\b")
			_mat_vertex_layer_base_regex[in_name] = rx
	
	return _mat_vertex_layer_base_regex

func _get_vertex_layer_below_regex() -> Dictionary:
	if _mat_vertex_layer_below_regex.is_empty():
		for in_name in MAT_VERTEX_LAYER_BELOW_FIELDS:
			var rx := RegEx.new()
			rx.compile("\\b" + in_name + "\\b")
			_mat_vertex_layer_below_regex[in_name] = rx
	
	return _mat_vertex_layer_below_regex

func _get_vertex_layer_blend_regex() -> Dictionary:
	if _mat_vertex_layer_blend_regex.is_empty():
		for in_name in MAT_VERTEX_LAYER_BLEND_FIELDS:
			var rx := RegEx.new()
			rx.compile("\\b" + in_name + "\\b")
			_mat_vertex_layer_blend_regex[in_name] = rx
	
	return _mat_vertex_layer_blend_regex

func _get_layer_data_out_regex(is_vertex: bool) -> Dictionary:
	if not is_vertex:
		if _data_fragment_layer_out_regex.is_empty():
			for in_name in DATA_FRAGMENT_LAYER_OUT_FIELDS:
				var rx := RegEx.new()
				rx.compile("\\b" + in_name + "\\b")
				_data_fragment_layer_out_regex[in_name] = rx
		return _data_fragment_layer_out_regex
	else:
		if _data_vertex_layer_out_regex.is_empty():
			for in_name in DATA_VERTEX_LAYER_OUT_FIELDS:
				var rx := RegEx.new()
				rx.compile("\\b" + in_name + "\\b")
				_data_vertex_layer_out_regex[in_name] = rx
		return _data_vertex_layer_out_regex

func _get_layer_data_below_regex(is_vertex: bool) -> Dictionary:
	if not is_vertex:
		if _data_fragment_layer_base_regex.is_empty():
			for in_name in DATA_FRAGMENT_LAYER_BASE_FIELDS:
				var rx := RegEx.new()
				rx.compile("\\b" + in_name + "\\b")
				_data_fragment_layer_base_regex[in_name] = rx
		return _data_fragment_layer_base_regex
	else:
		if _data_vertex_layer_base_regex.is_empty():
			for in_name in DATA_VERTEX_LAYER_BASE_FIELDS:
				var rx := RegEx.new()
				rx.compile("\\b" + in_name + "\\b")
				_data_vertex_layer_base_regex[in_name] = rx
		return _data_vertex_layer_base_regex

func _on_uniform_changed() -> void:
	update_uniforms(_ensure_assets())

func clear_uniforms() -> void:
	if not shader:
		return
	for prop in get_property_list():
		if prop.name.begins_with("shader_parameter/"):
			var param_name = prop.name.substr("shader_parameter/".length())
			set_shader_parameter(param_name, null)

func update_uniforms(assets: Array) -> void:
	layer_uniform_maps.clear()
	_rebuild_uniform_maps_from_assets(assets)
	if layer_uniform_maps.is_empty():
		return
	_connect_uniform_change_signals()
	clear_uniforms()
	copy_uniform_values(self, layer_uniform_maps)

func strip_comments(shader: String) -> String:
	var result := ""
	var i := 0
	var n := shader.length()
	var in_string := false

	while i < n:
		var c := shader[i]

		if in_string:
			if c == "\\" and i + 1 < n:
				result += c + shader[i + 1]
				i += 2
				continue
			result += c
			if c == "\"":
				in_string = false
			i += 1
			continue
		
		if c =="\"":
			in_string = true
			result += c
			i += 1
			continue
		
		if c == "/" and i + 1 < n and shader[i + 1] == "/":
			while i < n and shader[i] != "\n":
				i += 1
			continue
		
		if c == "/" and i + 1 < n and shader[i + 1] == "*":
			i += 2
			while i + 1 < n and not (shader[i] == "*" and shader[i + 1] == "/"):
				i += 1
			i += 2
			continue
		
		result += c
		i += 1

	return result
  
func get_includes(shader: String) -> Array:
	var directive_regex := RegEx.new()
	directive_regex.compile("#include[^\\n]*")

	var result : Array = []

	var matches := directive_regex.search_all(shader)
	for m in matches:
		result.append(m.get_string().strip_edges())

	return result

func get_global_macros(shader: String) -> Array:
	var result := []
	var pattern := RegEx.new()
	pattern.compile("^[A-Z][A-Z0-9_]+$")

	# Only scan the header, before the first render function body
	var header := shader
	var func_idx := shader.find("void vertex")
	if func_idx == -1:
		func_idx = shader.find("void fragment")
	if func_idx != -1:
		header = shader.substr(0, func_idx)

	for line in header.split("\n"):
		var t : String = line.strip_edges().trim_suffix(";")
		if t.begins_with("SETUP_") or t.begins_with("#") or t.is_empty():
			continue
		if t.begins_with("uniform ") or t.begins_with("shader_type"):
			continue
		if pattern.search(t) != null:
			result.append({"type": "statement", "text": t})

	return result

func get_fragment_macros(statements: Array) -> Array:
	var result := []
	var pattern := RegEx.new()
	pattern.compile("^[A-Z][A-Z0-9_]+$")

	for s in statements:
		if s.type != "statement":
			continue
		var line : String = s.text.strip_edges().trim_suffix(";")
		if line.begins_with("SETUP_"):
			continue
		if pattern.search(line) != null:
			result.append({"type": "statement", "text": s.text})
	
	return result

func get_mask_out(statements: Array, index: int) -> String:
	var mask_out := ""
	for s in statements:
		var line = s.text.strip_edges()

		if line.begins_with("LAYER_OUT_MASK"):
			var tokens = line.split("=")

			mask_out = "layer_%d_" % index + tokens[1].strip_edges()

	return mask_out 

func parse_uniforms(shader: String, is_mask: bool, index: int) -> Dictionary:
	var prefix := "s_layer_%d_" % index
	if is_mask:
		prefix = "m_layer_%d_" % index
	var directive_regex := RegEx.new()
	directive_regex.compile("#[^\\n]*")
	var layer_c := directive_regex.sub(shader, "", true)
	
	var prefixed_samplers : Array = []
	var sampler_identifiers : Array = []
	var prefixed_uniforms : Array = []
	var uniform_identifiers : Array = []
	var uniforms : Array = []

	for word in layer_c.split(";"):
		var line = word.strip_edges()
		if not line.begins_with("uniform "):
			continue
		uniforms.append(line)

	for uniform in uniforms:
		var colon_parts: Array = uniform.split(":", false, 1)
		var head: String = colon_parts[0].strip_edges()
		var tail: String = ""
		if colon_parts.size() > 1:
			tail = " :" + colon_parts[1]

		var head_tokens: Array = head.split(" ", false)
		var type: String = head_tokens[1]

		if type == "sampler2D" or type == "sampler2DArray":
			var sampler_id: String = head_tokens[2]
			var prefixed_sampler_id := prefix + sampler_id

			head_tokens[2] = prefixed_sampler_id
			var new_sampler_head := " ".join(head_tokens)

			sampler_identifiers.append(sampler_id)
			prefixed_samplers.append(new_sampler_head + tail  + ";")
			
			continue
		
		var uniform_id: String = head_tokens[2]
		var prefixed_uniform_id := prefix + uniform_id

		head_tokens[2] = prefixed_uniform_id
		var new_uniform_head := " ".join(head_tokens)

		uniform_identifiers.append(uniform_id)
		prefixed_uniforms.append(new_uniform_head + tail  + ";")

		

	return {"uniforms": prefixed_uniforms, "samplers": prefixed_samplers, "uniform_identifiers": uniform_identifiers, "sampler_identifiers": sampler_identifiers}

func parse_global_uniforms(shader: String, index: int) -> Dictionary:
	var directive_regex := RegEx.new()
	directive_regex.compile("#[^\\n]*")
	var layer_c := directive_regex.sub(shader, "", true)
	
	var uniforms : Array = []

	for word in layer_c.split(";"):
		var line = word.strip_edges()
		if not line.begins_with("global uniform "):
			continue
		uniforms.append(line + ";")

	return {"uniforms": uniforms}

func copy_uniform_values(mega_material: ShaderMaterial, layer_uniform_maps: Array) -> void:
	for layer in layer_uniform_maps:
		var identifiers: Array = layer["identifiers"]
		var index: int = layer["index"]
		var is_mask : bool = layer.get("is_mask", false)
		var prefix := "s_layer_%d_" % index
		if is_mask:
			prefix = "m_layer_%d_" % index

		var source_material: ShaderMaterial
		if layer.has("layer_material"):
			source_material = layer["layer_material"]
		elif layer.has("mask_material"):
			source_material = layer["mask_material"]
		else:
			continue

		for old_name in identifiers:
			var new_name : String = prefix + old_name
			var value = source_material.get_shader_parameter(old_name)
			if value != null:
				mega_material.set_shader_parameter(new_name, value)

		var sampler_ids: Array = layer.get("sampler_identifiers", [])
		for old_name in sampler_ids:
			var new_name : String = prefix + old_name
			var value = source_material.get_shader_parameter(old_name)
			if value != null:
				mega_material.set_shader_parameter(new_name, value)

func parse_varyings(shader: String, index: int) -> Dictionary:
	var directive_regex := RegEx.new()
	directive_regex.compile("#[^\\n]*")
	var layer_c := directive_regex.sub(shader, "", true)
	
	var result : Array = []
	var varyings : Array = []

	for word in layer_c.split(";"):
		var line = word.strip_edges()
		if not line.begins_with("varying "):
			continue
		varyings.append(line)

	for varying in varyings:
		var tokens: Array = varying.split(" ", false)
		var final_varying := " ".join(tokens) + ";"
		result.append(final_varying)
	
	return {"varyings": result}

func vertex_layer_out(index: int) -> String:
	if index == 0:
		return "\tlayerMatVertex mat_vertex_%d = DEFAULT_MAT_VERTEX;\n" % index
	else:
		return "\tlayerMatVertex mat_vertex_%d = final_mat_vertex;\n" % index

func fragment_layer_out(index: int) -> String:
	if index == 0:
		return "\tlayerMatFragment mat_fragment_%d = DEFAULT_MAT_FRAGMENT;\n" % index
	else:
		return "\tlayerMatFragment mat_fragment_%d = final_mat_fragment;\n" % index

func layer_data_out(index: int, is_vertex: bool) -> String:
	var type_name := "layerDataVertex" if is_vertex else "layerDataFragment"
	var var_name := "data_vertex_%d" if is_vertex else "data_fragment_%d"
	var default_name := "DEFAULT_DATA_VERTEX" if is_vertex else "DEFAULT_DATA_FRAGMENT"
	var final_name := "final_data_vertex" if is_vertex else "final_data_fragment"
	if index == 0:
		return "\t%s %s = %s;\n" % [type_name, var_name % index, default_name]
	else:
		return "\t%s %s = %s;\n" % [type_name, var_name % index, final_name]

func blend_fragment_block(fragment: String, index: int) -> String:
	var result := fragment

	if index == 0:
		result += "\n\n\t" + "layerMatFragment final_mat_fragment = mat_fragment_0;\n"

	return result

func blend_vertex_block(vertex: String, index: int) -> String:
	var result := vertex

	if index == 0:
		result += "\n\n\t" + "layerMatVertex final_mat_vertex = mat_vertex_0;\n"

	return result

func blend_data_fragment_block(fragment: String, index: int) -> String:
	var result := fragment

	if index == 0:
		result += "\n\n\t" + "layerDataFragment final_data_fragment = data_fragment_0;\n"

	return result

func blend_data_vertex_block(vertex: String, index: int) -> String:
	var result := vertex

	if index == 0:
		result += "\n\n\t" + "layerDataVertex final_data_vertex = data_vertex_0;\n"

	return result

func get_fragment(shader: String) -> String:
	var sig := RegEx.new()
	sig.compile("void\\s+fragment\\s*\\(\\s*\\)\\s*\\{")
	var m := sig.search(shader)
	if not m:
		return ""
	
	var i := m.get_end()
	var start := i
	var depth := 1
	var n := shader.length()

	while i < n and depth > 0:
		var c := shader[i]
		
		if c == "{":
			depth += 1
		elif c == "}":
			depth -= 1
		i += 1

	var end := i - 1
	return shader.substr(start, end - start)

func get_vertex(shader: String) -> String:
	var sig := RegEx.new()
	sig.compile("void\\s+vertex\\s*\\(\\s*\\)\\s*\\{")
	var m := sig.search(shader)
	if not m:
		return ""
	
	var i := m.get_end()
	var start := i
	var depth := 1
	var n := shader.length()

	while i < n and depth > 0:
		var c := shader[i]
		
		if c == "{":
			depth += 1
		elif c == "}":
			depth -= 1
		i += 1

	var end := i - 1
	return shader.substr(start, end - start)

func parse_fragment(body: String, index: int) -> Dictionary:
	var statements := []
	var identifiers := []
	var buffer := ""
	var paren_depth := 0
	var i := 0
	var n := body.length()

	# Get statements

	while i < n:
		var c := body[i]

		if c == "(":
			paren_depth += 1
		elif c == ")":
			paren_depth -= 1

		if c == "{" and paren_depth == 0:
			var head := buffer.strip_edges()
			statements.append({"type": "block_open", "text": head})
			buffer = ""
			i += 1
			continue
		
		if c == "}" and paren_depth == 0:
			var tail := buffer.strip_edges()
			if tail != "":
				statements.append({"type": "block_close", "text": ""})
			statements.append({"type": "block_close", "text": ""})
			buffer = ""
			i += 1
			continue
		
		if c == ";" and paren_depth == 0:
			var stmt := buffer.strip_edges()
			if stmt != "":
				statements.append({"type": "statement", "text": stmt})
			buffer = ""
			i += 1
			continue
		
		buffer += c
		i += 1
	
	var leftover := buffer.strip_edges()
	if leftover != "":
		statements.append({"type": "statement", "text": leftover})
	
	var indent_str: String = "\t"
	var fragment := ""
	var depth := 0
	
	######### MACROS

	var detected_macros := get_fragment_macros(statements)
	var macro_texts := {}
	for m in detected_macros:
		macro_texts[m["text"]] = true

	for s in statements:
		if s.type != "statement":
			continue
		var line : String = s.text.strip_edges().trim_suffix(";")
		if line.begins_with("SETUP_"):
			s.text = ""
		elif macro_texts.has(s.text):
			s.text = ""
	

	var mask_out := get_mask_out(statements, index)
	statements = parse_layer_data_in_out(statements, index, false)
	statements = parse_fragment_in_out(statements, index)

	for s in statements:
		match s.type:
			"block_open":
				fragment += indent_str.repeat(depth) + s.text + " {\n"
				depth += 1
			"block_close":
				depth = max(depth - 1, 0)
				fragment += indent_str.repeat(depth) + "}\n"
			"statement":

				for output in OUTPUTS:
					if s.text.begins_with(output):
						s.text = s.text.replace(s.text, "")
				
				if s.text.strip_edges() != "":
					fragment += indent_str.repeat(depth) + s.text + ";\n"
				

	fragment = fragment.indent("\t")

	for s in statements:
		var line: String = s.text.strip_edges()
		if line == "":
			continue

		var tokens: Array = line.split(" ", false)
		if tokens.size() < 2:
			continue

		if not TYPES.has(tokens[0]):
			continue

		var identifier: String = tokens[1]
		identifiers.append(identifier)

	return {"fragment": fragment, "identifiers": identifiers, "macros": detected_macros, "mask": mask_out}

func parse_vertex(body: String, index: int) -> Dictionary:
	var statements := []
	var identifiers := []
	var buffer := ""
	var paren_depth := 0
	var i := 0
	var n := body.length()

	while i < n:
		var c := body[i]

		if c == "(":
			paren_depth += 1
		elif c == ")":
			paren_depth -= 1

		if c == "{" and paren_depth == 0:
			var head := buffer.strip_edges()
			statements.append({"type": "block_open", "text": head})
			buffer = ""
			i += 1
			continue
		
		if c == "}" and paren_depth == 0:
			var tail := buffer.strip_edges()
			if tail != "":
				statements.append({"type": "block_close", "text": ""})
			statements.append({"type": "block_close", "text": ""})
			buffer = ""
			i += 1
			continue
		
		if c == ";" and paren_depth == 0:
			var stmt := buffer.strip_edges()
			if stmt != "":
				statements.append({"type": "statement", "text": stmt})
			buffer = ""
			i += 1
			continue
		
		buffer += c
		i += 1
	
	var leftover := buffer.strip_edges()
	if leftover != "":
		statements.append({"type": "statement", "text": leftover})
	
	
	var indent_str: String = "\t"
	var vertex := ""
	var depth := 0

	var has_setup := false
	for s in statements:
		if s.type == "statement" and "SETUP_" in s.text:
			has_setup = true
			break
	# if not has_setup:
	# 	push_error("Layer_%d ERROR ! Vertex Shader : missing SETUP_LAYER_VERTEX" % index)

	######### MACROS

	var detected_macros := get_fragment_macros(statements)
	var macro_texts := {}
	for m in detected_macros:
		macro_texts[m["text"]] = true

	for s in statements:
		if s.type != "statement":
			continue
		var line : String = s.text.strip_edges().trim_suffix(";")
		if line.begins_with("SETUP_"):
			s.text = ""
		elif macro_texts.has(s.text):
			s.text = ""
	
	

	statements = parse_layer_data_in_out(statements, index, true)
	statements = parse_vertex_in_out(statements, index)

	for s in statements:
		match s.type:
			"block_open":
				vertex += indent_str.repeat(depth) + s.text + " {\n"
				depth += 1
			"block_close":
				depth = max(depth - 1, 0)
				vertex += indent_str.repeat(depth) + "}\n"
			"statement":

				for output in OUTPUTS:
					if s.text.begins_with(output):
						s.text = s.text.replace(s.text, "")
				
				if s.text.strip_edges() != "":
					vertex += indent_str.repeat(depth) + s.text + ";\n"
				

	vertex = vertex.indent("\t")


	for s in statements:
		var line: String = s.text.strip_edges()
		if line == "":
			continue

		var tokens: Array = line.split(" ", false)
		if tokens.size() < 2:
			continue

		if not TYPES.has(tokens[0]):
			continue

		var identifier: String = tokens[1]
		identifiers.append(identifier)

	return {"statements": statements, "vertex": vertex, "identifiers": identifiers, "macros": detected_macros}

func parse_fragment_in_out(statements: Array, index: int):
	var result := []
	var out_struct_name := "mat_fragment_%d" % index
	var base_struct_name := "final_mat_fragment"
	var blend_struct_name := "mat_fragment_%d" % index
	var result_struct_name := "final_mat_fragment"
	
	var out_regex_map := _get_fragment_layer_out_regex()
	var base_regex_map := _get_fragment_layer_base_regex()
	var below_regex_map := _get_fragment_layer_below_regex()
	var blend_regex_map := _get_fragment_layer_blend_regex()

	for s in statements:
		if s.type != "statement":
			result.append(s)
			continue
		
		var line = s.text.strip_edges()
		
		if line.begins_with("SETUP_"):
			s.text = ""
			
		for out_name in out_regex_map:
			s.text = out_regex_map[out_name].sub(s.text,"%s.%s" % [out_struct_name, MAT_FRAGMENT_LAYER_OUT_FIELDS[out_name]], true)
		
		for blend_name in blend_regex_map:
			s.text = blend_regex_map[blend_name].sub(s.text,"%s.%s" % [blend_struct_name, MAT_FRAGMENT_LAYER_BLEND_FIELDS[blend_name]], true)

		if index == 0:
			var default_struct := "DEFAULT_MAT_FRAGMENT"
			for in_name in base_regex_map:
				s.text = base_regex_map[in_name].sub(
					s.text,
					"%s.%s" % [default_struct, MAT_FRAGMENT_LAYER_BASE_FIELDS[in_name]],
					true
				)
			for in_name in below_regex_map:
				s.text = below_regex_map[in_name].sub(
					s.text,
					"%s.%s" % [default_struct, MAT_FRAGMENT_LAYER_BELOW_FIELDS[in_name]],
					true
				)
		
		if index == 1:
			for in_name in base_regex_map:
				s.text = base_regex_map[in_name].sub(
					s.text,
					"%s.%s" % ["mat_fragment_%d" % (index - 1), MAT_FRAGMENT_LAYER_BASE_FIELDS[in_name]],
					true
				)
			for in_name in below_regex_map:
				s.text = below_regex_map[in_name].sub(
					s.text,
					"%s.%s" % ["mat_fragment_%d" % (index - 1), MAT_FRAGMENT_LAYER_BELOW_FIELDS[in_name]],
					true
				)

		elif index > 1:
			for in_name in base_regex_map:
				s.text = base_regex_map[in_name].sub(
					s.text,
					"%s.%s" % [base_struct_name, MAT_FRAGMENT_LAYER_BASE_FIELDS[in_name]],
					true
				)
			for in_name in below_regex_map:
				s.text = below_regex_map[in_name].sub(
					s.text,
					"%s.%s" % [base_struct_name, MAT_FRAGMENT_LAYER_BELOW_FIELDS[in_name]],
					true
				)

		result.append(s)
	
	return result

func parse_vertex_in_out(statements: Array, index: int):
	var result := []
	var out_struct_name := "mat_vertex_%d" % index
	var base_struct_name := "final_mat_vertex"
	var blend_struct_name := "mat_vertex_%d" % index
	var result_struct_name := "final_mat_vertex"
	
	var out_regex_map := _get_vertex_layer_out_regex()
	var base_regex_map := _get_vertex_layer_base_regex()
	var below_regex_map := _get_vertex_layer_below_regex()
	var blend_regex_map := _get_vertex_layer_blend_regex()

	for s in statements:
		if s.type != "statement":
			result.append(s)
			continue
		
		var line = s.text.strip_edges()
		
		if line.begins_with("SETUP_"):
			s.text = ""
			
		for out_name in out_regex_map:
			s.text = out_regex_map[out_name].sub(s.text,"%s.%s" % [out_struct_name, MAT_VERTEX_LAYER_OUT_FIELDS[out_name]], true)
		
		for blend_name in blend_regex_map:
			s.text = blend_regex_map[blend_name].sub(s.text,"%s.%s" % [blend_struct_name, MAT_VERTEX_LAYER_BLEND_FIELDS[blend_name]], true)

		if index == 0:
			var default_struct := "DEFAULT_MAT_VERTEX"
			for in_name in base_regex_map:
				s.text = base_regex_map[in_name].sub(
					s.text,
					"%s.%s" % [default_struct, MAT_VERTEX_LAYER_BASE_FIELDS[in_name]],
					true
				)
			for in_name in below_regex_map:
				s.text = below_regex_map[in_name].sub(
					s.text,
					"%s.%s" % [default_struct, MAT_VERTEX_LAYER_BELOW_FIELDS[in_name]],
					true
				)
		
		if index == 1:
			for in_name in base_regex_map:
				s.text = base_regex_map[in_name].sub(
					s.text,
					"%s.%s" % ["mat_vertex_%d" % (index - 1), MAT_VERTEX_LAYER_BASE_FIELDS[in_name]],
					true
				)
			for in_name in below_regex_map:
				s.text = below_regex_map[in_name].sub(
					s.text,
					"%s.%s" % ["mat_vertex_%d" % (index - 1), MAT_VERTEX_LAYER_BELOW_FIELDS[in_name]],
					true
				)

		elif index > 1:
			for in_name in base_regex_map:
				s.text = base_regex_map[in_name].sub(
					s.text,
					"%s.%s" % [base_struct_name, MAT_VERTEX_LAYER_BASE_FIELDS[in_name]],
					true
				)
			for in_name in below_regex_map:
				s.text = below_regex_map[in_name].sub(
					s.text,
					"%s.%s" % [base_struct_name, MAT_VERTEX_LAYER_BELOW_FIELDS[in_name]],
					true
				)

		result.append(s)
	
	return result

func parse_layer_data_in_out(statements: Array, index: int, is_vertex: bool):
	var result := []
	var out_struct_name := "data_vertex_%d" % index if is_vertex else "data_fragment_%d" % index
	var default_struct_name := "DEFAULT_DATA_VERTEX" if is_vertex else "DEFAULT_DATA_FRAGMENT"
	var final_struct_name := "final_data_vertex" if is_vertex else "final_data_fragment"
	var below_struct_name := ""

	if index == 0:
		below_struct_name = default_struct_name
	elif index == 1:
		below_struct_name = "data_vertex_%d" % (index - 1) if is_vertex else "data_fragment_%d" % (index - 1)
	else:
		below_struct_name = final_struct_name

	var out_regex_map := _get_layer_data_out_regex(is_vertex)
	var below_regex_map := _get_layer_data_below_regex(is_vertex)
	var out_field_map := DATA_VERTEX_LAYER_OUT_FIELDS if is_vertex else DATA_FRAGMENT_LAYER_OUT_FIELDS
	var below_field_map := DATA_VERTEX_LAYER_BASE_FIELDS if is_vertex else DATA_FRAGMENT_LAYER_BASE_FIELDS

	for s in statements:
		if s.type != "statement":
			result.append(s)
			continue

		for out_name in out_regex_map:
			s.text = out_regex_map[out_name].sub(s.text,"%s.%s" % [out_struct_name, out_field_map[out_name]], true)

		for in_name in below_regex_map:
			s.text = below_regex_map[in_name].sub(s.text,"%s.%s" % [below_struct_name, below_field_map[in_name]], true)

		result.append(s)
	
	return result

func prefix_vertex_fragment(body: String, identifiers: Array, is_mask: bool, index: int) -> String:
	var prefix := "s_layer_%d_" % index
	if is_mask:
		prefix = "m_layer_%d_" % index
	var result := body
	for identifier in identifiers:
		var regex := RegEx.new()
		regex.compile("\\b" + identifier + "\\b(?!\\s*\\()")
		result = regex.sub(result, prefix + identifier, true)
	return result

func prefix_vertex_fragment_samplers(all_fragment_funcs: Array, originals: Array, renames: Array) -> Array:
	var result := []
	var body := ""
	for fragment in all_fragment_funcs:
		body = fragment
		for i in originals.size():
			var regex := RegEx.new()
			regex.compile("\\b" + originals[i] + "\\b")
			body = regex.sub(body, renames[i], true)
		result.append(body)
	
	return result

func prefix_helper_funcs(body: String, identifiers: Array, is_mask: bool, index: int) -> String:
	var prefix := "s_layer_%d_" % index
	if is_mask:
		prefix = "m_layer_%d_" % index
	var result := body
	for identifier in identifiers:
		var regex := RegEx.new()
		regex.compile("\\b" + identifier + "\\b")
		result = regex.sub(result, prefix + identifier, true)
	return result

func strip_helper_funcs(shader: String) -> String:
	# Remove helper function definitions so the ;-based parsers (uniforms,
	# varyings) and header scanners get clean declaration chunks. Function
	# bodies are terminated by '}', not ';', so leaving them in glues the next
	# declaration onto the closing-brace chunk, e.g. "}\n\nvarying vec2 uv",
	# which makes begins_with("varying ") fail and the varying is dropped.
	var type_pattern := "(?:" + "|".join(TYPES) + ")"
	var sig := RegEx.new()
	sig.compile(type_pattern + "\\s+(\\w+)\\s*\\(([^)]*)\\)\\s*\\{")

	var skip_names := ["vertex", "fragment", "light", "start", "process", "sky", "fog"]
	var n := shader.length()
	var removals := []

	for m in sig.search_all(shader):
		var func_name := m.get_string(1)
		if func_name in skip_names:
			continue

		var i := m.get_end()
		var depth := 1
		while i < n and depth > 0:
			var c := shader[i]
			if c == "{":
				depth += 1
			elif c == "}":
				depth -= 1
			i += 1
		removals.append([m.get_start(), i])

	removals.sort_custom(func(a, b) -> bool: return a[0] > b[0])
	var result := shader
	for r in removals:
		result = result.substr(0, r[0]) + result.substr(r[1])

	return result

func parse_helper_funcs(shader: String, is_mask: bool, index: int) -> Dictionary:
	var type_pattern := "(?:" + "|".join(TYPES) + ")"
	var sig := RegEx.new()
	sig.compile(type_pattern + "\\s+(\\w+)\\s*\\(([^)]*)\\)\\s*\\{")

	var skip_names := ["vertex", "fragment", "light", "start", "process", "sky", "fog"]
	var raw_functions := []
	var identifiers := []
	var n := shader.length()

	for m in sig.search_all(shader):
		var func_name := m.get_string(1)
		if func_name in skip_names:
			continue

		var i := m.get_end()
		var start := i
		var depth := 1
		while i < n and depth > 0:
			var c := shader[i]
			if c == "{":
				depth += 1
			elif c == "}":
				depth -= 1
			i += 1
		var end := i - 1

		var params := m.get_string(2).strip_edges()
		var body := shader.substr(start, end - start)
		var return_type := m.get_string(0).split(func_name)[0].strip_edges()

		raw_functions.append(return_type + " " + func_name + "(" + params + ") {" + body + "}")
		identifiers.append(func_name)

	var prefix := "s_layer_%d_" % index
	if is_mask:
		prefix = "m_layer_%d_" % index
	var result := []

	for fn in raw_functions:
		var text : String = fn
		for identifier in identifiers:
			var regex := RegEx.new()
			regex.compile("\\b" + identifier + "\\b")
			text = regex.sub(text, prefix + identifier, true)
		result.append(text)

	return {"functions": result, "identifiers": identifiers}

func parse_switch_statements(shader: String) -> String:
	var sig := RegEx.new()
	sig.compile("switch\\s*\\(([^)]*)\\)\\s*\\{") 

	var matches := sig.search_all(shader)
	matches.reverse()

	var result := shader
	for m in matches:
		var i := m.get_end() - 1
		var depth := 1
		i += 1
		while i < result.length() and depth > 0:
			if result[i] == '{': depth += 1
			elif result[i] == '}': depth -= 1
			i += 1
		result = result.substr(0, i) + ";" + result.substr(i)

	return result

func dedup(array: Array) -> Array:
	var seen := {}
	var result := []
	for item in array:
		if not seen.has(item):
			seen[item] = true
			result.append(item)
	return result

func dedup_statements(statements: Array) -> Array:
	var seen := {}
	var result := []

	for s in statements:
		var key : String = s["type"] + "|" + s["text"].strip_edges()
		if not seen.has(key):
			seen[key] = true
			result.append(s)

	return result

func _macros_to_string(macros: Array) -> String:
	var lines := PackedStringArray()
	for m in macros:
		lines.append("\t" + m["text"] + ";")
	return "\n".join(lines) + "\n"

func dedup_samplers(layer_uniform_maps: Array):
	var sampler_rid_map := {}
	var originals := []
	var renames := []
	var uniforms := []
	var _to_remove := []

	for layer in layer_uniform_maps:
		var original: ShaderMaterial
		if layer.has("layer_material"):
			original = layer["layer_material"]
		elif layer.has("mask_material"):
			original = layer["mask_material"]
		else:
			continue
		var identifiers: Array = layer["sampler_identifiers"]
		var prefix := "s_layer_%d_" % layer["index"]
		if layer.get("is_mask", false):
			prefix = "m_layer_%d_" % layer["index"]
		uniforms.append_array(layer["sampler_uniforms"])

		for old_name in identifiers:
			var new_name : String = prefix + old_name
			var value = original.get_shader_parameter(old_name)

			if value != null:
				sampler_rid_map[new_name] = {"rid": value.get_rid(), "identifier": old_name}
	
	var first_seen := {}
	
	for uniform_name in sampler_rid_map:
		var rid: RID = sampler_rid_map[uniform_name]["rid"]
		var identifier: String = sampler_rid_map[uniform_name]["identifier"]
		if first_seen.has(rid):
			originals.append(uniform_name)
			renames.append(first_seen[rid])
			for uniform in uniforms:
				if uniform.contains(uniform_name):
					_to_remove.append(uniform)
					break
		else:
			first_seen[rid] = uniform_name
	
	for uniform in _to_remove:
		uniforms.erase(uniform)

	return {"sampler_uniforms": uniforms, "originals": originals, "renames": renames}

func _graph_is_file_backed() -> bool:
	# Only re-load the graph from disk when it is backed by an actual .tres file.
	# In-memory graphs (resource_path == "") and graphs embedded as sub-resources
	# (path contains "::") cannot be loaded via ResourceLoader.load() — attempting
	# to do so yields a Nil graph and cascading "Nonexistent function in base
	# 'Nil'" errors. In those cases the shared in-memory instance is the source
	# of truth and must be kept.
	return layer_graph != null \
		and layer_graph.resource_path != "" \
		and not layer_graph.resource_path.contains("::")

func _rebuild_layers() -> void:
	if layer_graph == null:
		return
	var old_active: Array[bool] = []
	for ml in layers:
		old_active.append(ml.active)
	layers = layer_graph._build_layers_from_graphs()
	for i in mini(layers.size(), old_active.size()):
		layers[i].active = old_active[i]

func _collect_layer_assets() -> Array:
	if layer_graph == null:
		push_warning("LayerStack '%s': no LayerGraph assigned" % resource_name)
		return []
	# Reuse the cached resource instance — the graph editor edits that shared
	# instance in place, so keeping it lets this stack live-sync uniforms via
	# signals instead of re-reading the file (which would orphan the link).
	if _graph_is_file_backed():
		layer_graph = ResourceLoader.load(layer_graph.resource_path) as LayerGraph

	var assets: Array = []
	

	for i in layers.size():
		var layer: MaterialLayer = layers[i]
		var active := layer != null and layer.active
		var mask_active := layer != null and layer.mask_active
		var layer_mat: ShaderMaterial = layer.layer_material if active else null
		var layer_shader: Shader = layer_mat.shader if layer_mat and layer_mat.shader else null
		var mask_mat: ShaderMaterial = layer.mask_material if active else null
		var mask_shader: Shader = mask_mat.shader if mask_mat and mask_mat.shader else null
		assets.append({
			"slot": i,
			"layer": layer,
			"layer_mat": layer_mat,
			"layer_shader": layer_shader,
			"mask_active": mask_active,
			"mask_mat": mask_mat,
			"mask_shader": mask_shader,
		})

	return assets

func _generate_code(assets: Array) -> String:
	var mega_shader := PackedStringArray()

	var all_includes := []
	var all_global_macros := []
	var all_varyings := []
	var all_uniforms := []
	var all_global_uniforms := []
	var all_helper_funcs := []
	var all_layer_outs := []
	var all_fragment_macros := []
	var all_fragment_funcs := []
	var all_vertex_macros := []
	var all_vertex_funcs := []
	var all_identifiers := []
	var vertex_identifiers := []

	layer_uniform_maps.clear()
	

	for asset in assets:
		var slot: int = asset["slot"]
		var mask_active: bool = asset["mask_active"]

		var layer_shader: Shader = asset["layer_shader"]
		if layer_shader == null:
			continue
		
		var mask_shader: Shader = asset["mask_shader"]
		var mask_c := ""

		if mask_active and mask_shader:
			mask_c = strip_comments(mask_shader.code)

		var layer_c := strip_comments(layer_shader.code)

		# Strip helper funcs so the ;-split parsers (uniforms/varyings) see clean
		# declaration chunks. Render funcs and declarations are preserved.
		var mask_body := strip_helper_funcs(mask_c)
		var layer_body := strip_helper_funcs(layer_c)

		var mask_fragment_body := ""
		var mask_vertex_body := ""

		if mask_active:
			var mask_includes = get_includes(mask_body)
			var mask_global_macros := get_global_macros(mask_body)
			var mask_uniforms = parse_uniforms(mask_body, true, slot)
			var mask_global_uniforms = parse_global_uniforms(mask_body, slot)
			var mask_varyings = parse_varyings(mask_body, slot)
			var mask_helper_funcs := parse_helper_funcs(mask_c, true, slot)
			var mask_fragment := get_fragment(mask_c)
			var mask_parsed_fragment := parse_fragment(mask_fragment, slot)
			mask_fragment_body = mask_parsed_fragment["fragment"]
			mask_fragment_body = parse_switch_statements(mask_parsed_fragment["fragment"])
			var mask_vertex := get_vertex(mask_c)
			var mask_parsed_vertex := parse_vertex(mask_vertex, slot)
			mask_vertex_body = mask_parsed_vertex["vertex"]

			all_includes.append_array(mask_includes)
			all_global_macros.append_array(mask_global_macros)
			all_uniforms.append_array(mask_uniforms["uniforms"])
			all_global_uniforms.append_array(mask_global_uniforms["uniforms"])
			all_varyings.append_array(mask_varyings["varyings"])
			all_helper_funcs.append_array(mask_helper_funcs["functions"])
			all_vertex_macros.append_array(mask_parsed_vertex["macros"])
			all_fragment_macros.append_array(mask_parsed_fragment["macros"])

			all_identifiers.append_array(mask_uniforms["uniform_identifiers"])
			all_identifiers.append_array(mask_uniforms["sampler_identifiers"])
			all_identifiers.append_array(mask_helper_funcs["identifiers"])
			all_identifiers.append_array(mask_parsed_fragment["identifiers"])

			vertex_identifiers.append_array(mask_uniforms["uniform_identifiers"])
			vertex_identifiers.append_array(mask_uniforms["sampler_identifiers"])
			vertex_identifiers.append_array(mask_helper_funcs["identifiers"])
			vertex_identifiers.append_array(mask_parsed_vertex["identifiers"])

			layer_uniform_maps.append({
				"mask_material": asset["mask_mat"],
				"identifiers": mask_uniforms["uniform_identifiers"],
				"sampler_identifiers": mask_uniforms["sampler_identifiers"],
				"sampler_uniforms": mask_uniforms["samplers"],
				"index": slot,
				"is_mask": true,
			})

			mask_fragment_body = prefix_helper_funcs(mask_fragment_body, mask_helper_funcs["identifiers"], true, slot)
			mask_fragment_body = prefix_vertex_fragment(mask_fragment_body, all_identifiers, true, slot)
			mask_vertex_body = prefix_vertex_fragment(mask_vertex_body, vertex_identifiers, true, slot)
		
		var layer_global_macros := get_global_macros(layer_body)
		
		var layer_includes := get_includes(layer_body)

		var layer_uniforms := parse_uniforms(layer_body, false, slot)
		var layer_global_uniforms := parse_global_uniforms(layer_body, slot)

		var parsed_varyings := parse_varyings(layer_body, slot)

		var layer_helper_funcs := parse_helper_funcs(layer_c, false, slot)
		
		var layer_fragment := get_fragment(layer_c)
		var layer_parsed_fragment := parse_fragment(layer_fragment, slot)
		var layer_fragment_body: String = layer_parsed_fragment["fragment"]
		layer_fragment_body = parse_switch_statements(layer_parsed_fragment["fragment"])

		
		var layer_vertex := get_vertex(layer_c)
		var layer_parsed_vertex := parse_vertex(layer_vertex, slot)
		var layer_vertex_body: String = layer_parsed_vertex["vertex"]

		layer_uniform_maps.append({
			"layer_material": asset["layer_mat"],
			"identifiers": layer_uniforms["uniform_identifiers"],
			"sampler_identifiers": layer_uniforms["sampler_identifiers"],
			"sampler_uniforms": layer_uniforms["samplers"],
			"index": slot,
			"is_mask": false,
		})

		all_global_macros.append_array(layer_global_macros)

		all_varyings.append_array(parsed_varyings["varyings"])
		all_varyings = dedup(all_varyings)
		all_helper_funcs.append_array(layer_helper_funcs["functions"])
		all_helper_funcs.append("\n")
		
		all_includes.append_array(layer_includes)
		all_includes = dedup(all_includes)

		all_vertex_macros.append_array(layer_parsed_vertex["macros"])
		
		all_fragment_macros.append_array(layer_parsed_fragment["macros"])
		
		all_uniforms.append_array(layer_uniforms["uniforms"])
		all_uniforms.append("\n")
		all_global_uniforms.append_array(layer_global_uniforms["uniforms"])
		all_global_uniforms = dedup(all_global_uniforms)
		all_uniforms.append("\n")

		all_identifiers.append_array(layer_uniforms["uniform_identifiers"])
		all_identifiers.append_array(layer_uniforms["sampler_identifiers"])
		all_identifiers.append_array(layer_helper_funcs["identifiers"])
		all_identifiers.append_array(layer_parsed_fragment["identifiers"])

		vertex_identifiers.append_array(layer_uniforms["uniform_identifiers"])
		vertex_identifiers.append_array(layer_uniforms["sampler_identifiers"])
		vertex_identifiers.append_array(layer_helper_funcs["identifiers"])
		vertex_identifiers.append_array(layer_parsed_vertex["identifiers"])

		layer_fragment_body = prefix_helper_funcs(layer_fragment_body, layer_helper_funcs["identifiers"], false, slot)
		layer_fragment_body = prefix_vertex_fragment(layer_fragment_body, all_identifiers, false, slot)
		layer_fragment_body = blend_data_fragment_block(layer_fragment_body,slot)
		layer_fragment_body = blend_fragment_block(layer_fragment_body, slot)

		all_fragment_funcs.append(layer_data_out(slot, false))
		all_fragment_funcs.append(fragment_layer_out(slot))
		all_fragment_funcs.append(layer_fragment_body)
		all_fragment_funcs.append("\n\n")
		all_fragment_funcs.append("\tfinal_data_fragment = data_fragment_%d;" % slot)
		all_fragment_funcs.append("\n\n")
		all_fragment_funcs.append("\tfinal_mat_fragment = mat_fragment_%d;" % slot)
		all_fragment_funcs.append("\n\n")
		all_fragment_funcs.append(mask_fragment_body)
		all_fragment_funcs.append("\n\n")
		all_fragment_funcs.append("\tfinal_data_fragment = data_fragment_%d;" % slot)
		all_fragment_funcs.append("\n\n")
		all_fragment_funcs.append("\tfinal_mat_fragment = mat_fragment_%d;" % slot)
		all_fragment_funcs.append("\n")

		layer_vertex_body = prefix_vertex_fragment(layer_vertex_body, vertex_identifiers, false, slot)
		layer_vertex_body = blend_data_vertex_block(layer_vertex_body, slot)
		layer_vertex_body = blend_vertex_block(layer_vertex_body, slot)

		all_vertex_funcs.append(layer_data_out(slot, true))
		all_vertex_funcs.append(vertex_layer_out(slot))
		all_vertex_funcs.append(layer_vertex_body)
		all_vertex_funcs.append("\tfinal_data_vertex = data_vertex_%d;" % slot)
		all_vertex_funcs.append("\n\n")
		all_vertex_funcs.append(mask_vertex_body)
		all_vertex_funcs.append("\tfinal_mat_vertex = mat_vertex_%d;" % slot)
		all_vertex_funcs.append("\n\n")
	
	var deduped_samplers = dedup_samplers(layer_uniform_maps)
	all_uniforms.append_array(deduped_samplers["sampler_uniforms"])

	all_vertex_macros = dedup_statements(all_vertex_macros)
	all_fragment_macros = dedup_statements(all_fragment_macros)
	all_global_macros = dedup_statements(all_global_macros)

	all_fragment_funcs = prefix_vertex_fragment_samplers(all_fragment_funcs, deduped_samplers["originals"], deduped_samplers["renames"])
	all_vertex_funcs = prefix_vertex_fragment_samplers(all_vertex_funcs, deduped_samplers["originals"], deduped_samplers["renames"])
	all_helper_funcs = prefix_vertex_fragment_samplers(all_helper_funcs, deduped_samplers["originals"], deduped_samplers["renames"])
	mega_shader.append("////// Shader generated using Material Layers //////")
	mega_shader.append("\n\n")
	mega_shader.append("shader_type spatial;")
	mega_shader.append("\n\n")
	mega_shader.append("\n".join(all_includes))
	var global_macro_lines := PackedStringArray()
	for gm in all_global_macros:
		global_macro_lines.append(gm["text"] + ";")
	if not global_macro_lines.is_empty():
		mega_shader.append("\n" + "\n".join(global_macro_lines) + "\n")
	mega_shader.append("\n")
	mega_shader.append("\n".join(all_varyings))
	mega_shader.append("\n")
	mega_shader.append("\n".join(all_uniforms))
	mega_shader.append("\n")
	mega_shader.append("\n".join(all_global_uniforms))
	mega_shader.append("\n")
	mega_shader.append("\n".join(all_helper_funcs))

	mega_shader.append("void vertex() {\n")
	mega_shader.append(DEFAULT_MAT_VERTEX_OUTPUT)
	mega_shader.append(DEFAULT_DATA_VERTEX_OUTPUT)
	mega_shader.append(_macros_to_string(all_vertex_macros))
	mega_shader.append("".join(all_vertex_funcs))
	mega_shader.append("\t" + MAT_VERTEX_OUTPUTS)
	mega_shader.append("}")
	mega_shader.append("\n\n")

	mega_shader.append("void fragment() {")
	mega_shader.append("\n")
	mega_shader.append(DEFAULT_DATA_FRAGMENT_OUTPUT)
	mega_shader.append(DEFAULT_MAT_FRAGMENT_OUTPUT)
	mega_shader.append(_macros_to_string(all_fragment_macros))
	mega_shader.append("".join(all_fragment_funcs))
	mega_shader.append("\t" + MAT_FRAGMENT_OUTPUTS)
	mega_shader.append("}")

	return "".join(mega_shader)

func _auto_compile_on_load() -> void:
	_connect_live_sync()
	if shader and not layers.is_empty():
		ensure_assets_and_update()

func _rebuild_uniform_maps_from_assets(assets: Array) -> void:
	for asset in assets:
		var slot: int = asset["slot"]
		var mask_active: bool = asset["mask_active"]

		var mask_shader: Shader = asset["mask_shader"]

		if mask_active and mask_shader:
			var mask_uniforms = _cached_layer_uniforms(mask_shader, true, slot)

			layer_uniform_maps.append({
				"mask_material": asset["mask_mat"],
				"identifiers": mask_uniforms["uniform_identifiers"],
				"sampler_identifiers": mask_uniforms["sampler_identifiers"],
				"sampler_uniforms": mask_uniforms["samplers"],
				"index": slot,
				"is_mask": true,
			})

		var layer_shader: Shader = asset["layer_shader"]
		if layer_shader == null:
			continue

		var layer_uniforms := _cached_layer_uniforms(layer_shader, false, slot)

		layer_uniform_maps.append({
			"layer_material": asset["layer_mat"],
			"identifiers": layer_uniforms["uniform_identifiers"],
			"sampler_identifiers": layer_uniforms["sampler_identifiers"],
			"sampler_uniforms": layer_uniforms["samplers"],
			"index": slot,
			"is_mask": false,
		})

func _connect_uniform_change_signals() -> void:
	for layer_map in layer_uniform_maps:
		var source_material: ShaderMaterial = null
		if layer_map.has("layer_material"):
			source_material = layer_map["layer_material"]
		elif layer_map.has("mask_material"):
			source_material = layer_map["mask_material"]
		if source_material != null and not source_material.changed.is_connected(_on_uniform_changed):
			source_material.changed.connect(_on_uniform_changed)

func ensure_assets_and_update() -> void:
	update_uniforms(_ensure_assets())

func compile() -> void:
	

	if layer_graph == null:
		print_rich("No [color=#75ff13]LayerGraph[/color] assigned. Please assign a [color=#75ff13]LayerGraph[/color] and try again.")
		return

	# Reuse the cached instance so this stack stays linked to the graph the
	# editor is editing live (signals keep uniforms in sync after Generate).
	if _graph_is_file_backed():
		layer_graph = ResourceLoader.load(layer_graph.resource_path) as LayerGraph

	# Skip generating when nothing feeds the OutputNode — keeps the blend
	# material intact instead of wiping it back to an empty graph.
	var has_output := false
	for node in layer_graph.nodes:
		if node["type"] != "OutputNode":
			continue
		for con in layer_graph.connections:
			if con.to == node["name"]:
				has_output = true
				break
		if has_output:
			break

	if not has_output:
		print_rich("[color=#75ff13]LayerGraph[/color] [b]'%s'[/b] has no connection feeding its [b]OutputNode[/b]." % layer_graph.resource_name)
		return

	# Rebuild the layer list to match the current graph structure. Layers are
	# stack-owned duplicates, so they are only rebuilt on Generate — never on
	# load, which would discard manual parameter edits saved in this stack.
	_rebuild_layers()

	# Force a fresh collection — otherwise _ensure_assets() serves the
	# previous generate's cached assets.
	_invalidate_assets()

	_mat_fragment_layer_out_regex.clear()
	_mat_fragment_layer_base_regex.clear()
	_mat_fragment_layer_below_regex.clear()
	_mat_fragment_layer_blend_regex.clear()
	_mat_vertex_layer_out_regex.clear()
	_mat_vertex_layer_base_regex.clear()
	_mat_vertex_layer_below_regex.clear()
	_mat_vertex_layer_blend_regex.clear()
	_data_fragment_layer_out_regex.clear()
	_data_fragment_layer_base_regex.clear()
	layer_uniform_maps.clear()
	var assets := _ensure_assets()
	var code := _generate_code(assets)
	print_rich("Generated " + "[color=#75ff13]LayerStack")

	var sh: Shader
	if self.shader != null and self.shader is Shader:
		sh = self.shader
	else:
		sh = Shader.new()
	sh.code = code
	sh.emit_changed()

	if sh.resource_path != "":
		ResourceSaver.save(sh, sh.resource_path)
	elif self.shader == null:
		self.shader = sh

	# Keep the manual-edit live path wired so edits to the (rebuilt) layer
	# materials propagate to the mega material after Generate.
	_connect_uniform_change_signals()

	# Only push uniform values when sync is enabled — Generate alone must not
	# touch the mega material's uniforms.
	if sync_uniforms:
		for prop in get_property_list():
			if prop.name.begins_with("shader_parameter/"):
				var param_name = prop.name.substr("shader_parameter/".length())
				set_shader_parameter(param_name, null)

		copy_uniform_values(self, layer_uniform_maps)

func sync_uniforms_from_graph() -> void:
	if layer_graph == null:
		return
	if not sync_uniforms:
		_clear_live_sync()
		return
	layer_graph.sync_uniforms_to_layers(layers)
	update_uniforms(_ensure_assets())
	_connect_live_sync()

var _live_connected_materials: Dictionary = {}

func _clear_live_sync() -> void:
	if layer_graph and layer_graph.graph_updated.is_connected(_on_graph_updated):
		layer_graph.graph_updated.disconnect(_on_graph_updated)
	for mat in _live_connected_materials:
		if is_instance_valid(mat) and mat.changed.is_connected(_on_material_changed):
			mat.changed.disconnect(_on_material_changed)
	_live_connected_materials = {}

func _connect_live_sync() -> void:
	if layer_graph == null:
		return
	if not sync_uniforms:
		_clear_live_sync()
		return
	if not layer_graph.graph_updated.is_connected(_on_graph_updated):
		layer_graph.graph_updated.connect(_on_graph_updated)
	var new_set := {}
	for node in layer_graph.nodes:
		for key in ["surface", "mask", "overlay", "data"]:
			if node.has(key):
				var mat: ShaderMaterial = node[key]
				if mat != null and not mat.changed.is_connected(_on_material_changed):
					mat.changed.connect(_on_material_changed)
				new_set[mat] = true
	for mat in _live_connected_materials:
		if is_instance_valid(mat) and not new_set.has(mat):
			if mat.changed.is_connected(_on_material_changed):
				mat.changed.disconnect(_on_material_changed)
	_live_connected_materials = new_set

func _on_graph_updated() -> void:
	_connect_live_sync()
	sync_uniforms_from_graph()

func _on_material_changed() -> void:
	sync_uniforms_from_graph()

