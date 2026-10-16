@tool
class_name LayerGraphEdit
extends GraphEdit

const SURFACE_ICON = preload("res://addons/material_layers/icons/surfaceMaterial.svg")
const MASK_ICON = preload("res://addons/material_layers/icons/maskMaterial.svg")
const OVERLAY_ICON = preload("res://addons/material_layers/icons/overlayMaterial.svg")
const DATA_ICON = preload("res://addons/material_layers/icons/dataMaterial.svg")
const OUTPUT_ICON = preload("res://addons/material_layers/icons/outputIcon.svg")

var inspector_container: PanelContainer
var file_container: PanelContainer
var inspector_panel: VBoxContainer
var file_panel: VBoxContainer
var inspector: EditorInspector
var picker: EditorResourcePicker
var _inspector_target: Resource

var graph := LayerGraph.new()
var file_dialog: EditorFileDialog
var _save_mode := false
var _current_path := ""
var _node_seq := 0


var node_popup := PopupMenu.new()
var file_popup := PopupMenu.new()
var options_popup := PopupMenu.new()
var resolution_popup := PopupMenu.new()
var _file_button: Button
var _options_button: Button
var _graph_label: Label
var _spawn_at := Vector2.ZERO

func _ready():
	var popup_style = node_popup.get_theme_stylebox("panel").duplicate()
	popup_style.corner_radius_top_left = 4
	popup_style.corner_radius_bottom_left = 4
	popup_style.corner_radius_top_right = 4
	popup_style.corner_radius_bottom_right = 4

	node_popup.add_theme_constant_override("v_separation", 16)
	node_popup.add_theme_constant_override("item_start_padding", 8)
	node_popup.add_theme_constant_override("item_end_padding", 8)
	
	node_popup.add_icon_item(SURFACE_ICON, "SurfaceNode", 0)
	node_popup.add_icon_item(MASK_ICON, "MaskNode", 1)
	node_popup.add_icon_item(OVERLAY_ICON, "OverlayNode", 2)
	node_popup.add_icon_item(DATA_ICON, "DataNode", 3)
	node_popup.add_icon_item(OUTPUT_ICON, "OutputNode", 4)

	add_child(node_popup)
	node_popup.id_pressed.connect(_on_node_popup)
	
	file_popup.add_theme_constant_override("v_separation", 16)
	file_popup.add_theme_constant_override("item_start_padding", 8)
	file_popup.add_theme_constant_override("item_end_padding", 8)

	file_popup.add_item("New", 0)
	file_popup.add_item("Open", 1)
	file_popup.add_item("Save", 2)
	file_popup.add_item("Save as", 3)
	
	add_child(file_popup)
	file_popup.id_pressed.connect(_on_file_popup)

	options_popup.add_theme_constant_override("v_separation", 16)
	options_popup.add_theme_constant_override("item_start_padding", 8)
	options_popup.add_theme_constant_override("item_end_padding", 8)

	resolution_popup.add_theme_constant_override("v_separation", 16)
	resolution_popup.add_theme_constant_override("item_start_padding", 8)
	resolution_popup.add_theme_constant_override("item_end_padding", 8)
	resolution_popup.name = "PreviewResolution"

	resolution_popup.add_check_item("64x64", 0)
	resolution_popup.add_check_item("128x128", 1)
	resolution_popup.add_check_item("256x256", 2)
	resolution_popup.add_check_item("512x512", 3)
	options_popup.add_child(resolution_popup)

	options_popup.add_check_item("Transparent Preview", 0)
	options_popup.add_submenu_item("Preview Resolution", "PreviewResolution")
	
	add_child(options_popup)
	options_popup.id_pressed.connect(_on_options_popup)
	resolution_popup.id_pressed.connect(_on_resolution_popup)

	gui_input.connect(_on_graph_gui_input)

	node_selected.connect(_on_node_selected)
	node_deselected.connect(_on_node_deselected)
	connection_request.connect(_on_connection_request)
	disconnection_request.connect(_on_disconnection_request)
	begin_node_move.connect(_on_begin_node_move)
	end_node_move.connect(_on_end_node_move)
	
	inspector_container = $"../InspectorContainer"
	inspector_container.visible = false
	inspector_panel = $"../InspectorContainer/VBoxContainer"

	file_container = $"../FileContainer"
	file_container.visible = false
	file_panel = $"../FileContainer/VBoxContainer"

	var toolbar_hbox = get_menu_hbox()

	var file_button := Button.new()
	file_button.text = "File"
	file_button.pressed.connect(_on_file_button_pressed)
	toolbar_hbox.add_child(file_button)
	toolbar_hbox.move_child(file_button, 0)
	_file_button = file_button

	var options_button := Button.new()
	options_button.text = "Options"
	options_button.pressed.connect(_on_options_button_pressed)
	toolbar_hbox.add_child(options_button)
	toolbar_hbox.move_child(options_button, 1)
	_options_button = options_button

	_graph_label = Label.new()
	_graph_label.text = graph.resource_name
	toolbar_hbox.add_child(_graph_label)


	inspector = EditorInspector.new()
	inspector.size_flags_vertical = Control.SIZE_EXPAND_FILL
	inspector_panel.add_child(inspector)
	inspector.visible = false

	file_dialog = EditorFileDialog.new()
	file_dialog.access = EditorFileDialog.ACCESS_FILESYSTEM
	file_dialog.add_filter("*.tres", "Layer Graph")
	file_dialog.file_selected.connect(_on_graph_file_selected)
	add_child(file_dialog)


func _undo_redo() -> EditorUndoRedoManager:
	return EditorInterface.get_editor_undo_redo()


func _get_mouse_pos() -> Vector2:
	return _canvas_pos_from_local(get_local_mouse_position())


func _canvas_pos_from_local(local: Vector2) -> Vector2:
	var pos := (local + scroll_offset) / zoom
	if snapping_enabled:
		pos = pos.snapped(Vector2(snapping_distance, snapping_distance))
	return pos


func _on_node_popup(id: int) -> void:
	var what := ""
	match id:
		0: what = "surfaceNode"
		1: what = "maskNode"
		2: what = "overlayNode"
		3: what = "dataNode"
		4: what = "outputNode"
	if not what.is_empty():
		if what == "outputNode" and _has_output_node():
			return
		_on_button_pressed(what, _spawn_at)


func _on_file_button_pressed() -> void:
	file_popup.position = (_file_button.global_position + Vector2(0, _file_button.size.y)) if _file_button else get_global_mouse_position()
	file_popup.popup()


func _on_file_popup(id: int) -> void:
	match id:
		0: _on_new_pressed()
		1: _on_open_pressed()
		2: _on_save_pressed()
		3: _on_save_as_pressed()


func _on_options_button_pressed() -> void:
	options_popup.set_item_checked(0, _is_transparent_bg_enabled())
	_sync_resolution_checks()
	options_popup.position = (_options_button.global_position + Vector2(0, _options_button.size.y)) if _options_button else get_global_mouse_position()
	options_popup.popup()


func _on_options_popup(id: int) -> void:
	match id:
		0: _on_transparent_bg_pressed()


func _on_transparent_bg_pressed() -> void:
	var enabled := not _is_transparent_bg_enabled()
	ProjectSettings.set_setting("material_layers/preview_transparent", enabled)
	ProjectSettings.save()
	options_popup.set_item_checked(0, enabled)
	for node in get_children():
		if node is LayerGraphNode:
			node.set_transparent_bg(enabled)


func _is_transparent_bg_enabled() -> bool:
	return ProjectSettings.get_setting("material_layers/preview_transparent", false)


func _sync_resolution_checks() -> void:
	var idx := _current_preview_size_index()
	for i in _PREVIEW_SIZES.size():
		resolution_popup.set_item_checked(i, i == idx)


const _PREVIEW_SIZES := [
	Vector2i(64, 64),
	Vector2i(128, 128),
	Vector2i(256, 256),
	Vector2i(512, 512),
]


func _current_preview_size_index() -> int:
	var size := int(ProjectSettings.get_setting("material_layers/preview_resolution", 128))
	for i in _PREVIEW_SIZES.size():
		if _PREVIEW_SIZES[i].x == size:
			return i
	return 1


func _on_resolution_popup(id: int) -> void:
	var size: Vector2i = _PREVIEW_SIZES[id]
	ProjectSettings.set_setting("material_layers/preview_resolution", size.x)
	ProjectSettings.save()
	for i in _PREVIEW_SIZES.size():
		resolution_popup.set_item_checked(i, i == id)
	for node in get_children():
		if node is LayerGraphNode:
			node.set_preview_resolution(size)

func _on_graph_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton \
	and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		_spawn_at = _get_mouse_pos()
		node_popup.position = get_global_mouse_position()
		node_popup.popup()


func _update_material_previews(graph: LayerGraph) -> void:
	for node in graph.nodes:
		if not has_node(String(node["name"])):
			continue
		var graph_node := get_node(String(node["name"])) as LayerGraphNode
		if node["type"] == "SurfaceNode":
			graph_node.set_preview_material(node["surface"])
		elif node["type"] == "MaskNode":
			graph_node.set_preview_material(node["mask"])
		elif node["type"] == "OverlayNode":
			graph_node.set_preview_material(node["overlay"])
		elif node["type"] == "DataNode":
			graph_node.set_preview_material(node["data"])
				


func _update_graph():
	var data := _serialize()
	# Preserve this editor's graph identity (resource_path + UID) by copying the
	# freshly-serialized data INTO the existing instance instead of replacing it.
	# Re-creating via LayerGraph.new() every save issued a brand-new UID, which
	# severed the link from any LayerStack still holding the earlier instance and
	# made Godot embed the graph as a unique SubResource on save.
	graph.resource_name = data.resource_name
	graph.graph_name = data.graph_name
	graph.scroll_offset = data.scroll_offset
	graph.zoom = data.zoom
	graph.nodes = data.nodes
	graph.connections = data.connections

	var parsed_nodes := _get_node_chain(graph)
	var indexed_nodes : Array = parsed_nodes["indexed_nodes"]
	var output_node : String = parsed_nodes["output_node"]
	
	graph.indexed_nodes = indexed_nodes
	graph.output_node = output_node

	_update_layer_label(graph)
	_update_material_previews(graph)
	_sync_graph_label()
	graph.graph_updated.emit()


func _sync_graph_label() -> void:
	if _graph_label == null:
		return
	var name := ""
	# Prefer a real file path; an embedded sub-resource path (contains "::") is
	# not a user-facing name, so fall through to a clean resource_name.
	if _current_path != "" and not _current_path.contains("::"):
		name = _current_path.get_file()
	elif graph.resource_name != "" and graph.resource_name != "layer_graph" and not graph.resource_name.contains("::"):
		name = graph.resource_name
	if name.is_empty():
		name = "Unnamed Graph"
	_graph_label.text = name


func _update_layer_label(graph: LayerGraph) -> void:
	for set in graph.indexed_nodes:
		var node_name := str(set["name"])
		if has_node(node_name):
			var node := get_node(node_name) as LayerGraphNode
			node.layer_label.text = "Layer %d" % int(set["index"])


func _load_graph(path: String) -> void:
	var loaded = ResourceLoader.load(path, "", ResourceLoader.CACHE_MODE_REPLACE)
	_deserialize(loaded)
	_update_graph()
	_current_path = path


func open_graph(graph_resource: LayerGraph) -> void:
	graph = graph_resource
	_current_path = graph_resource.resource_path
	_deserialize(graph_resource)
	_update_graph()


func _get_node_chain(graph: LayerGraph) ->Dictionary:
	var chain := []
	var blend_nodes := []
	var current := ""
	
	var indexed_nodes := []
	var output_node := ""

	# Detect output node and store
	for node in graph.nodes:
		if node["type"] == "OutputNode":
			current = node["name"]
			output_node = node["name"]
			break

	if current.is_empty():
		# Always return the full contract shape — callers read both keys.
		return {"indexed_nodes": [], "output_node": ""}

	# Set chain start to node before output
	var output_fed := false
	for con in graph.connections:
		if con.to == current:
			current = con.from
			output_fed = true
			break

	if not output_fed:
		# Output exists but nothing plugs into it — nothing to generate.
		return {"indexed_nodes": [], "output_node": ""}

	# Walk from last non-output node backwards
	var seen := {}
	while true:
		if seen.has(current):
			break  # cycle guard — never revisit a node
		seen[current] = true
		chain.append(current)

		var current_node_type := get_node_type(current, graph)

		# Detect mask node
		if current_node_type == "MaskNode":
			var port_0 := ""
			var port_1 := ""

			# Isolate port 0 and 1
			for con in graph.connections:
				if con.to == current:
					if con.to_port == 0:
						port_0 = con.from
					elif con.to_port == 1:
						port_1 = con.from

			# Save port 0 node as blend and mask node
			if not port_0.is_empty():
				blend_nodes.append({
					"blend": port_0,
					"mask": current
				})
			
			if port_1.is_empty():
				break
			
			current = port_1
		
		else:
			# Walk all other nodes and append
			var prev := ""
			for con in graph.connections:
				if con.to == current:
					prev = con.from
					break
			
			if prev.is_empty():
				break
			
			current = prev

	chain.reverse()


	# Index nodes
	var index := 0
	for node in chain:
		if get_node_type(node, graph) == "MaskNode":
			indexed_nodes.append({
				"type": "mask",
				"name": node,
				"index": index,
			})
		
		else:
			indexed_nodes.append({
				"type": "layer",
				"name": node,
				"index": index,
			})
		
		index += 1
	

	# Assign mask index to blend surface
	for blend in blend_nodes:
		var blend_name = blend["blend"]
		var mask_name = blend["mask"]
		var mask_index := -1
		for indexed in indexed_nodes:
			if indexed["name"] == mask_name:
				mask_index = indexed["index"]
				break
		if mask_index >= 0:
			indexed_nodes.append({
				"type": "blend",
				"name": blend_name,
				"index": mask_index,
			})

	return {"indexed_nodes": indexed_nodes, "output_node": output_node}


func get_node_type(node_name: StringName, graph: LayerGraph) -> String:
	for node in graph.nodes:
		if node["name"] == node_name:
			return node["type"]
	return ""


func _on_button_pressed(what: String, at: Variant = null) -> void:
	match what:
		"surfaceNode":
			_spawn("SurfaceNode", at)
		"maskNode":
			_spawn("MaskNode", at)
		"overlayNode":
			_spawn("OverlayNode", at)
		"dataNode":
			_spawn("DataNode", at)
		"outputNode":
			for child in get_children():
				if child is OutputNode:
					return
			_spawn("OutputNode", at)


func _spawn(type: String, at: Variant = null) -> void:
	var dict := {
		"type": type,
		"name": "%s_%d" % [type, _node_seq],
		"position": at if at != null else Vector2.ZERO,
		"preview_visible": false,
	}
	_node_seq += 1
	var ur := _undo_redo()
	ur.create_action("Add %s" % type)
	ur.add_do_method(self, "_add_node_dict", dict)
	ur.add_undo_method(self, "_remove_node_dict", dict)
	ur.commit_action()


func _material_node_type(material: Resource) -> String:
	if material is SurfaceMaterial:
		return "SurfaceNode"
	if material is OverlayMaterial:
		return "OverlayNode"
	if material is MaskMaterial:
		return "MaskNode"
	if material is DataMaterial:
		return "DataNode"
	return ""


func _spawn_from_material(material: Resource, at: Vector2) -> void:
	var type := _material_node_type(material)
	if type.is_empty():
		push_warning("Drop ignored: unsupported material type %s" % material.get_class())
		return
	var dict := {
		"type": type,
		"name": "%s_%d" % [type, _node_seq],
		"position": at,
		"preview_visible": false,
		"res": material,
	}
	_node_seq += 1
	var ur := _undo_redo()
	ur.create_action("Add %s" % type)
	ur.add_do_method(self, "_add_node_dict", dict)
	ur.add_undo_method(self, "_remove_node_dict", dict)
	ur.commit_action()


func _can_drop_data(_position: Vector2, data: Variant) -> bool:
	if not (data is Dictionary):
		return false
	if data.get("type") != "files":
		return false
	for path in data.get("files", []):
		var res := load(String(path))
		if res and not _material_node_type(res).is_empty():
			return true
	return false


func _drop_data(position: Vector2, data: Variant) -> void:
	if not (data is Dictionary):
		return
	var at := _canvas_pos_from_local(position)
	for path in data.get("files", []):
		var res := load(String(path))
		if res and not _material_node_type(res).is_empty():
			_spawn_from_material(res, at)
			at += Vector2(24, 24)


var _drag_positions := {}


func _on_begin_node_move() -> void:
	_drag_positions.clear()
	for child in get_children():
		if child is GraphNode:
			_drag_positions[String(child.name)] = child.position_offset


func _on_end_node_move() -> void:
	if _drag_positions.is_empty():
		return
	var moved := {}
	for child in get_children():
		if child is GraphNode:
			var name := String(child.name)
			if _drag_positions.has(name) and _drag_positions[name] != child.position_offset:
				moved[name] = child.position_offset
	if moved.is_empty():
		_drag_positions.clear()
		return
	var ur := _undo_redo()
	ur.create_action("Move %d node%s" % [moved.size(), "s" if moved.size() > 1 else ""])
	for name in moved:
		ur.add_do_method(self, "_set_node_position", name, moved[name])
		ur.add_undo_method(self, "_set_node_position", name, _drag_positions[name])
	ur.commit_action()
	_drag_positions.clear()


func _set_node_position(name: String, position: Vector2) -> void:
	if has_node(name):
		(get_node(name) as GraphNode).position_offset = position


func _has_output_node() -> bool:
	for child in get_children():
		if child is OutputNode:
			return true
	return false


func _on_node_selected(node: Node) -> void:
	if node is OutputNode:
		inspector_container.visible = false
		return
	inspector_container.visible = true
	if picker:
		picker.queue_free()
		picker = null
	inspector.visible = false

	if node is SurfaceNode:
		picker = EditorResourcePicker.new()
		picker.base_type = "SurfaceMaterial"
		picker.edited_resource = node.surface
		picker.resource_changed.connect(func(res: Resource) -> void:
			node.surface = res
			_refresh_material_inspector()
			_update_graph()
		)
		inspector_panel.add_child(picker)
		inspector_panel.move_child(picker, 0)

		inspector.visible = true
		_refresh_material_inspector()
	
	if node is MaskNode:
		picker = EditorResourcePicker.new()
		picker.base_type = "MaskMaterial"
		picker.edited_resource = node.mask
		picker.resource_changed.connect(func(res: Resource) -> void:
			node.mask = res
			_refresh_material_inspector()
			_update_graph()
		)
		inspector_panel.add_child(picker)
		inspector_panel.move_child(picker, 0)
	
		inspector.visible = true
		_refresh_material_inspector()
	
	if node is OverlayNode:
		picker = EditorResourcePicker.new()
		picker.base_type = "OverlayMaterial"
		picker.edited_resource = node.overlay
		picker.resource_changed.connect(func(res: Resource) -> void:
			node.overlay = res
			_refresh_material_inspector()
			_update_graph()
		)
		inspector_panel.add_child(picker)
		inspector_panel.move_child(picker, 0)
	
		inspector.visible = true
		_refresh_material_inspector()

	if node is DataNode:
		picker = EditorResourcePicker.new()
		picker.base_type = "DataMaterial"
		picker.edited_resource = node.data
		picker.resource_changed.connect(func(res: Resource) -> void:
			node.data = res
			_refresh_material_inspector()
			_update_graph()
		)
		inspector_panel.add_child(picker)
		inspector_panel.move_child(picker, 0)
	
		inspector.visible = true
		_refresh_material_inspector()


func _refresh_material_inspector() -> void:
	if picker and picker.edited_resource:
		_inspector_target = picker.edited_resource
		inspector.edit(_inspector_target)
	else:
		_clear_material_inspector()


func _clear_material_inspector() -> void:
	# Keep the edited resource referenced until the inspector detaches, so the
	# EditorInspector never tries to disconnect from a freed resource.
	_inspector_target = null
	if inspector:
		inspector.edit(null)
	if inspector_container:
		inspector_container.visible = false
	if picker:
		picker.queue_free()
		picker = null
	inspector.visible = false


func _on_connection_request(from_node: StringName, from_port: int, to_node: StringName, to_port: int) -> void:
	var connections := get_connection_list()

	# Remember any connection being replaced on this port
	var replaced := {}
	for con in connections:
		if con.to_node == to_node and con.to_port == to_port:
			replaced = con
			break

	var from := get_node(String(from_node)) as LayerGraphNode
	var to := get_node(String(to_node)) as LayerGraphNode

	# Reject before connecting
	if from is MaskNode and to is SurfaceNode:
		return
	elif from is SurfaceNode and to is SurfaceNode:
		return
	elif from.get_port_type(true, from_port) == LayerGraphNode.TYPE_BASE and to.get_port_type(false, to_port) == LayerGraphNode.TYPE_BLEND:
		return
	
	# Reject overlay to output without incoming connections
	if (from is OverlayNode or from is DataNode) and to is OutputNode:
		var has_incoming := false
		for con in connections:
			if con.to_node == from_node:
				has_incoming = true
				break
		if not has_incoming:
			return
	

	# Reject surface feeding mask if already connected to mask
	if to is SurfaceNode:
		for con in connections:
			if con.from_node == to_node:
				var target = get_node(String(con.to_node))
				if target is MaskNode and con.to_port == 0:
					return

	var ur := _undo_redo()
	ur.create_action("Connect")
	ur.add_do_method(self, "_do_connect", from_node, from_port, to_node, to_port, replaced)
	ur.add_undo_method(self, "_undo_connect", from_node, from_port, to_node, to_port, replaced)
	ur.commit_action()


func _do_connect(from_node: StringName, from_port: int, to_node: StringName, to_port: int, replaced: Dictionary) -> void:
	if not replaced.is_empty():
		disconnect_node(replaced.from_node, replaced.from_port, replaced.to_node, replaced.to_port)
	connect_node(from_node, from_port, to_node, to_port)
	_update_graph()


func _undo_connect(from_node: StringName, from_port: int, to_node: StringName, to_port: int, replaced: Dictionary) -> void:
	if is_node_connected(from_node, from_port, to_node, to_port):
		disconnect_node(from_node, from_port, to_node, to_port)
	if not replaced.is_empty():
		connect_node(replaced.from_node, replaced.from_port, replaced.to_node, replaced.to_port)
	_update_graph()


func _on_disconnection_request(from_node: StringName, from_port: int, to_node: StringName, to_port: int) -> void:
	if not is_node_connected(from_node, from_port, to_node, to_port):
		return
	var ur := _undo_redo()
	ur.create_action("Disconnect")
	ur.add_do_method(self, "disconnect_node", from_node, from_port, to_node, to_port)
	ur.add_undo_method(self, "connect_node", from_node, from_port, to_node, to_port)
	ur.commit_action()
	_update_graph()


func _on_node_deselected(_node: Node) -> void:
	_clear_material_inspector()


func _graph_has_focus() -> bool:
	var focus := get_viewport().gui_get_focus_owner()
	if focus == null:
		return false
	return focus == self or is_ancestor_of(focus)


func _input(event: InputEvent) -> void:
	if not (event is InputEventKey and event.pressed and not event.echo):
		return
	if not (event.ctrl_pressed \
	or event.keycode == KEY_DELETE \
	or event.keycode == KEY_BACKSPACE \
	or event.keycode == KEY_X \
	or event.keycode == KEY_A):
		return
	if not is_visible_in_tree():
		return
	if not _graph_has_focus():
		return
	var focus := get_viewport().gui_get_focus_owner()
	if focus is TextEdit or focus is LineEdit:
		return
	if not event.ctrl_pressed:
		match event.keycode:
			KEY_DELETE, KEY_BACKSPACE, KEY_X:
				_delete_selected_nodes()
				_on_node_deselected(null)
			KEY_A:
				for node in get_children():
					if node is GraphNode:
						node.selected = true
				_on_node_deselected(null)
		get_viewport().set_input_as_handled()
		return
	match event.keycode:
		KEY_C:
			_copy_selected()
			get_viewport().set_input_as_handled()
		KEY_X:
			_cut_selected()
			_on_node_deselected(null)
			get_viewport().set_input_as_handled()
		KEY_V:
			_paste_at(_get_mouse_pos())
			get_viewport().set_input_as_handled()
		KEY_D:
			_duplicate_selected()
			_on_node_deselected(null)
			get_viewport().set_input_as_handled()
		KEY_A:
			for node in get_children():
				if node is GraphNode:
					node.selected = true
			_on_node_deselected(null)
			get_viewport().set_input_as_handled()


func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.shift_pressed and not event.ctrl_pressed:
			var at := _get_mouse_pos()
			match event.keycode:
				KEY_S:
					_spawn("SurfaceNode", at)
					return
				KEY_C:
					_spawn("MaskNode", at)
					return
				KEY_V:
					_spawn("OverlayNode", at)
					return
				KEY_D:
					_spawn("DataNode", at)
					return
				KEY_T:
					if not _has_output_node():
						_spawn("OutputNode", at)
					return

func _delete_selected_nodes() -> void:
	var to_delete: Array[GraphNode] = []
	for node in get_children():
		if node is GraphNode and node.selected:
			to_delete.append(node)
	if to_delete.is_empty():
		return
	var dicts: Array[Dictionary] = []
	var conns: Array[Dictionary] = []
	for node in to_delete:
		dicts.append(_node_to_dict(node))
	for con in get_connection_list():
		for node in to_delete:
			if con.from_node == node.name or con.to_node == node.name:
				conns.append(con)
				break
	var ur := _undo_redo()
	ur.create_action("Delete %d node%s" % [to_delete.size(), "s" if to_delete.size() > 1 else ""])
	ur.add_do_method(self, "_delete_nodes_do", dicts, conns)
	ur.add_undo_method(self, "_delete_nodes_undo", dicts, conns)
	ur.commit_action()


func _delete_nodes_do(dicts: Array, conns: Array) -> void:
	for con in conns:
		if is_node_connected(con.from_node, con.from_port, con.to_node, con.to_port):
			disconnect_node(con.from_node, con.from_port, con.to_node, con.to_port)
	for dict in dicts:
		var name := String(dict["name"])
		if has_node(name):
			var node := get_node(name) as GraphNode
			remove_child(node)
			node.queue_free()
	_update_graph()


func _delete_nodes_undo(dicts: Array, conns: Array) -> void:
	for dict in dicts:
		_add_node_dict(dict)
	for con in conns:
		if has_node(String(con.from_node)) and has_node(String(con.to_node)):
			if not is_node_connected(con.from_node, con.from_port, con.to_node, con.to_port):
				connect_node(con.from_node, con.from_port, con.to_node, con.to_port)
	_update_graph()


static var _clipboard_nodes: Array = []
static var _clipboard_connections: Array = []


func _copy_selected() -> void:
	_clipboard_nodes.clear()
	_clipboard_connections.clear()
	var selected_names := {}
	for child in get_children():
		if child is GraphNode and child.selected:
			_clipboard_nodes.append(_node_to_dict(child as LayerGraphNode))
			selected_names[String(child.name)] = true
	if _clipboard_nodes.is_empty():
		return
	for con in get_connection_list():
		if selected_names.has(String(con.from_node)) and selected_names.has(String(con.to_node)):
			_clipboard_connections.append({
				"from": con.from_node,
				"from_port": con.from_port,
				"to": con.to_node,
				"to_port": con.to_port,
			})


func _cut_selected() -> void:
	_copy_selected()
	if not _clipboard_nodes.is_empty():
		_delete_selected_nodes()
		_on_node_deselected(null)


func _clipboard_bounds_origin() -> Vector2:
	var origin := Vector2.INF
	for dict in _clipboard_nodes:
		origin = origin.min(Vector2(dict["position"]))
	return origin if origin != Vector2.INF else Vector2.ZERO


func _paste_at(at: Vector2) -> void:
	if _clipboard_nodes.is_empty():
		return
	var targets: Array = []
	var name_map := {}
	var origin := _clipboard_bounds_origin()
	for dict in _clipboard_nodes:
		var copy: Dictionary = dict.duplicate()
		if String(copy["type"]) == "OutputNode" and _has_output_node():
			continue
		var new_name := "%s_%d" % [copy["type"], _node_seq]
		_node_seq += 1
		name_map[String(copy["name"])] = new_name
		copy["name"] = new_name
		copy["position"] = at + (Vector2(copy["position"]) - origin)
		targets.append(copy)
	if targets.is_empty():
		return
	var conns := []
	for con in _clipboard_connections:
		var from_name := name_map.get(String(con["from"]))
		var to_name := name_map.get(String(con["to"]))
		if from_name == null or to_name == null:
			continue
		conns.append({
			"from": from_name,
			"from_port": con.from_port,
			"to": to_name,
			"to_port": con.to_port,
		})
	var ur := _undo_redo()
	ur.create_action("Paste %d node%s" % [targets.size(), "s" if targets.size() > 1 else ""])
	ur.add_do_method(self, "_paste_nodes_do", targets, conns)
	ur.add_undo_method(self, "_paste_nodes_undo", targets, conns)
	ur.commit_action()
	_on_node_deselected(null)


func _paste_nodes_do(dicts: Array, conns: Array) -> void:
	for dict in dicts:
		_add_node_dict(dict)
	for con in conns:
		var from_name := String(con["from"])
		var to_name := String(con["to"])
		if has_node(from_name) and has_node(to_name):
			connect_node(from_name, int(con["from_port"]), to_name, int(con["to_port"]))
	_update_graph()


func _paste_nodes_undo(dicts: Array, conns: Array) -> void:
	for dict in dicts:
		_remove_node_dict(dict)
	_update_graph()


func _duplicate_selected() -> void:
	_copy_selected()
	if _clipboard_nodes.is_empty():
		return
	_paste_at(_clipboard_bounds_origin() + Vector2(32, 32))


func _on_new_pressed() -> void:
	_clear_material_inspector()
	clear_connections()
	for child in get_children():
		if child is GraphNode:
			remove_child(child)
			child.queue_free()
	graph = LayerGraph.new()
	_current_path = ""
	_node_seq = 0
	_update_graph()


func _on_save_pressed() -> void:
	# Embedded sub-resource paths (e.g. a graph saved inside a LayerStack scene,
	# like "res://materialLayering.tscn::Resource_xxx.tres") are not standalone
	# files — saving to them fails, so fall through to the save-as dialog.
	if _current_path != "" and not _current_path.contains("::"):
		_save_to_path(_current_path)
	else:
		_open_save_dialog()


func _on_save_as_pressed() -> void:
	_open_save_dialog()


func _open_save_dialog() -> void:
	_save_mode = true
	file_dialog.file_mode = EditorFileDialog.FILE_MODE_SAVE_FILE
	file_dialog.current_file = _current_path.get_file() if _current_path != "" and not _current_path.contains("::") else "layer_graph.tres"
	file_dialog.popup_centered()


func _on_open_pressed() -> void:
	_save_mode = false
	file_dialog.file_mode = EditorFileDialog.FILE_MODE_OPEN_FILE
	file_dialog.popup_centered()


func _save_to_path(path: String) -> void:
	if not path.ends_with(".tres"):
		path += ".tres"
	_update_graph()
	if graph.nodes.is_empty():
		push_warning("Layer Graph: saving an EMPTY graph to %s" % path)
	graph.graph_name = path.get_file()
	graph.resource_name = path.get_file()
	var err := graph.save_to(path)
	if err == OK:
		graph.take_over_path(path)
		EditorInterface.get_resource_filesystem().scan()
		print("Layer Graph: saved %s (%d nodes, %d connections, %d indexed)" % [path, graph.nodes.size(), graph.connections.size(), graph.indexed_nodes.size()])
		_current_path = path
		_sync_graph_label()
	else:
		push_error("Layer Graph: could not save to %s (error %s)" % [path, err])


func _on_graph_file_selected(path: String) -> void:
	if _save_mode:
		_save_to_path(path)
	else:
		var loaded := ResourceLoader.load(path, "", ResourceLoader.CACHE_MODE_REPLACE) as LayerGraph
		if loaded:
			loaded.resource_name = path.get_file()
			graph = loaded
			_deserialize(loaded)
			_update_graph()
			_current_path = path
		else:
			push_error("Layer Graph: %s is not a valid LayerGraph" % path)


func _serialize() -> LayerGraph:
	var graph := LayerGraph.new()
	# Preserve the current saved name instead of resetting to "layer_graph" on
	# every serialize — otherwise the toolbar label and the saved resource would
	# both lose the graph's file name.
	graph.resource_name = self.graph.resource_name
	graph.scroll_offset = scroll_offset
	graph.zoom = zoom

	var index := 0
	var surface_index := 0
	var mask_index := 0
	var overlay_index := 0
	var data_index := 0

	for child in get_children():
		if child is SurfaceNode:
			graph.nodes.append({
				"type": "SurfaceNode",
				"name": child.name,
				"position": child.position_offset,
				"layer_name": child.get_layer_name(),
				"surface": child.surface,
				"surface_index": surface_index,
				"index": index,
				"preview_visible": child.preview_visible
			})
			surface_index += 1
			index += 1
		elif child is MaskNode:
			graph.nodes.append({
				"type": "MaskNode",
				"name": child.name,
				"position": child.position_offset,
				"layer_name": child.get_layer_name(),
				"mask": child.mask,
				"mask_index": mask_index,
				"index": index,
				"preview_visible": child.preview_visible
			})
			mask_index += 1
			index += 1
		elif child is OverlayNode:
			graph.nodes.append({
				"type": "OverlayNode",
				"name": child.name,
				"position": child.position_offset,
				"layer_name": child.get_layer_name(),
				"overlay": child.overlay,
				"overlay_index": overlay_index,
				"index": index,
				"preview_visible": child.preview_visible
			})
			overlay_index += 1
			index += 1
		elif child is DataNode:
			graph.nodes.append({
				"type": "DataNode",
				"name": child.name,
				"position": child.position_offset,
				"layer_name": child.get_layer_name(),
				"data": child.data,
				"data_index": data_index,
				"index": index,
				"preview_visible": child.preview_visible
			})
			data_index += 1
			index += 1
		elif child is OutputNode:
			graph.nodes.append({
				"type": "OutputNode",
				"name": child.name,
				"position": child.position_offset,
				"layer_name": child.get_layer_name(),
			})

	for con in get_connection_list():
		graph.connections.append({
			"from": con.from_node,
			"from_port": con.from_port,
			"to": con.to_node,
			"to_port": con.to_port,
		})

	return graph


func _deserialize(graph: LayerGraph) -> void:
	_clear_material_inspector()
	clear_connections()

	var to_remove: Array[GraphNode] = []
	for child in get_children():
		if child is GraphNode:
			to_remove.append(child)
	for node in to_remove:
		remove_child(node)
		node.queue_free()

	var name_map := {}
	_node_seq = 0
	for data in graph.nodes:
		var node := _create_node(str(data.get("type")))
		if node == null:
			continue
		var wanted := str(data.get("name"))
		node.name = wanted
		node.position_offset = data.get("position", Vector2.ZERO)
		node.set("preview_visible", data.get("preview_visible", false))
		if node is SurfaceNode:
			node.surface = data.get("surface") as SurfaceMaterial
		elif node is MaskNode:
			node.mask = data.get("mask") as MaskMaterial
		elif node is OverlayNode:
			node.overlay = data.get("overlay") as OverlayMaterial
		elif node is DataNode:
			node.data = data.get("data") as DataMaterial
		add_child(node)
		# Godot may sanitize reserved ('@'-prefixed) names on tree entry —
		# remember the mapping so saved connections still resolve.
		if String(node.name) != wanted:
			name_map[wanted] = String(node.name)
		node.set_layer_name(str(data.get("layer_name", "")))

	for con in graph.connections:
		var from_name := str(con.get("from"))
		var to_name := str(con.get("to"))
		from_name = name_map.get(from_name, from_name)
		to_name = name_map.get(to_name, to_name)
		if not has_node(from_name) or not has_node(to_name):
			push_warning("Layer Graph: skipping connection %s -> %s (node missing after restore)" % [from_name, to_name])
			continue
		connect_node(from_name, int(con.get("from_port")), to_name, int(con.get("to_port")))

	scroll_offset = graph.scroll_offset
	zoom = graph.zoom


func _add_node_dict(dict: Dictionary) -> void:
	var type := String(dict["type"])
	var node := _create_node(type)
	if node == null:
		return
	node.name = String(dict.get("name", "%s_%d" % [type, _node_seq - 1]))
	node.position_offset = dict.get("position", Vector2.ZERO)
	node.set("preview_visible", dict.get("preview_visible", false))
	match type:
		"SurfaceNode":
			node.surface = dict.get("res") as SurfaceMaterial
		"MaskNode":
			node.mask = dict.get("res") as MaskMaterial
		"OverlayNode":
			node.overlay = dict.get("res") as OverlayMaterial
		"DataNode":
			node.data = dict.get("res") as DataMaterial
	add_child(node)
	_update_graph()


func _remove_node_dict(dict: Dictionary) -> void:
	var name := String(dict["name"])
	if not has_node(name):
		return
	var node := get_node(name) as LayerGraphNode
	for con in get_connection_list():
		if con.from_node == node.name or con.to_node == node.name:
			disconnect_node(con.from_node, con.from_port, con.to_node, con.to_port)
	remove_child(node)
	node.queue_free()
	_update_graph()


func _node_to_dict(node: LayerGraphNode) -> Dictionary:
	var dict := {
		"type": "",
		"name": String(node.name),
		"position": node.position_offset,
		"preview_visible": node.preview_visible,
	}
	if node is SurfaceNode:
		dict["type"] = "SurfaceNode"
		dict["res"] = node.surface
	elif node is MaskNode:
		dict["type"] = "MaskNode"
		dict["res"] = node.mask
	elif node is OverlayNode:
		dict["type"] = "OverlayNode"
		dict["res"] = node.overlay
	elif node is DataNode:
		dict["type"] = "DataNode"
		dict["res"] = node.data
	elif node is OutputNode:
		dict["type"] = "OutputNode"
	return dict


func _create_node(type: String) -> LayerGraphNode:
	var node: LayerGraphNode
	match type:
		"SurfaceNode":
			node = SurfaceNode.new()
		"MaskNode":
			node = MaskNode.new()
		"OverlayNode":
			node = OverlayNode.new()
		"DataNode":
			node = DataNode.new()
		"OutputNode":
			node = OutputNode.new()
	if node == null:
		return null
	# Clean, collision-free names — '@'-names are reserved by Godot and get
	# silently mangled on restore, breaking connection lookups.
	node.name = "%s_%d" % [type, _node_seq]
	_node_seq += 1
	if node is OutputNode:
		node.save_requested.connect(_on_save_pressed)
	return node


