@icon ("res://addons/material_layers/icons/layerGraph.svg")
@tool
class_name LayerGraph
extends Resource

signal graph_updated

@export_storage var scroll_offset: Vector2 = Vector2.ZERO
@export_storage var zoom: float = 1.0

@export_storage var graph_name: String = "layer_graph"
@export_storage var nodes: Array[Dictionary] = []
@export_storage var connections: Array[Dictionary] = []
@export_storage var indexed_nodes : Array = []
@export_storage var output_node : String = ""

func _ready() -> void:
	pass


func _build_layers_from_graphs() -> Array[MaterialLayer]:
	var material_layers : Array[MaterialLayer] = []

	for set in indexed_nodes:
		var name : String = set["name"]
		var type : String = set["type"]
		var index : int = set["index"]

		if type == "layer":
			var ml := MaterialLayer.new()
			ml.layer_index = index
			for node in nodes:
				if node["name"] == name:
					match node["type"]:
						"SurfaceNode":
							ml.resource_name = "ML: " + node["name"]
							ml.name = node["layer_name"] if (node["layer_name"] != "") else "Layer"
							ml.layer_material = node["surface"]
							ml.mask_active = false
						"DataNode":
							ml.resource_name = "ML: " + node["name"]
							ml.name = node["layer_name"] if (node["layer_name"] != "") else "Layer"
							ml.layer_material = node["data"]
							ml.mask_active = false
						"OverlayNode":
							ml.resource_name = "ML: " + node["name"]
							ml.name = node["layer_name"] if (node["layer_name"] != "") else "Layer"
							ml.layer_material = node["overlay"]
							ml.mask_active = false
			material_layers.append(ml)

		elif type == "mask":
			var ml := MaterialLayer.new()
			ml.layer_index = index
			ml.mask_active = true

			# get the mask material
			for node in nodes:
				if node["name"] == name and node["type"] == "MaskNode":
					ml.resource_name = "ML: " + node["name"]
					ml.name = node["layer_name"] if (node["layer_name"] != "") else "Mask"
					ml.mask_material = node["mask"]
					break

			# find the blend surface with the same index
			for blend_set in indexed_nodes:
				if blend_set["type"] == "blend" and blend_set["index"] == set["index"]:
					for node in nodes:
						if node["name"] == blend_set["name"]:
							ml.resource_name = ml.resource_name + " + " + node["name"]
							ml.name = node["layer_name"] + " + " + ml.name if (node["layer_name"] != "" and ml.name != "") else "Surface" + " + " + ml.name
							ml.layer_material = node["surface"]
							break
					break

			material_layers.append(ml)

	return material_layers


func _init() -> void:
	if resource_name.is_empty():
		resource_name = "layer_graph"

func sync_uniforms_to_layers(layers: Array[MaterialLayer]) -> void:
	var ml_idx := 0
	for set in indexed_nodes:
		if ml_idx >= layers.size():
			break
		var name: String = set["name"]
		var type: String = set["type"]
		var ml: MaterialLayer = layers[ml_idx]

		if type == "layer":
			for node in nodes:
				if node["name"] == name:
					match node["type"]:
						"SurfaceNode":
							_copy_uniforms(node["surface"], ml.layer_material)
						"DataNode":
							_copy_uniforms(node["data"], ml.layer_material)
						"OverlayNode":
							_copy_uniforms(node["overlay"], ml.layer_material)
					break

		elif type == "mask":
			for node in nodes:
				if node["name"] == name and node["type"] == "MaskNode":
					_copy_uniforms(node["mask"], ml.mask_material)
					break
			for blend_set in indexed_nodes:
				if blend_set["type"] == "blend" and blend_set["index"] == set["index"]:
					for node in nodes:
						if node["name"] == blend_set["name"]:
							_copy_uniforms(node["surface"], ml.layer_material)
							break
					break

		ml_idx += 1

func _copy_uniforms(source: ShaderMaterial, target: ShaderMaterial) -> void:
	if source == null or target == null:
		return
	for prop in source.get_property_list():
		var prop_name := String(prop.name)
		if not prop_name.begins_with("shader_parameter/"):
			continue
		var param := prop_name.substr("shader_parameter/".length())
		target.set_shader_parameter(param, source.get_shader_parameter(param))

func save_to(path: String) -> Error:
	return ResourceSaver.save(self, path)
