@tool
class_name LayerGraphNode
extends GraphNode

const TYPE_BLEND := 1
const TYPE_BASE := 2
const TYPE_BOTH := 3

const ICON_BLEND : Texture2D = preload("res://addons/material_layers/icons/blendIcon.svg")
const ICON_BASE : Texture2D = preload("res://addons/material_layers/icons/baseIcon.svg")
const ICON_BOTH : Texture2D = preload("res://addons/material_layers/icons/bothIcon.svg")

const PORT_COLOR : Color = "#c8c8c8"
const PORT_COLOR_HOVER : Color = "#ffffff"

var port_types = {
	"input": [],
	"output": [],
}

var layer_label: Label
var name_field: TextEdit
var material_preview: TextureRect
var preview_viewport: SubViewport
var preview_instance: MeshInstance3D
var preview_material: Material
var preview_visible := false
var preview_environment := preload("res://addons/material_layers/src/graph/layer_graph_env.tres")

static var _preview_sphere_mesh: SphereMesh


static func _get_sphere_mesh() -> SphereMesh:
	if _preview_sphere_mesh == null:
		_preview_sphere_mesh = SphereMesh.new()
	return _preview_sphere_mesh


func _ready() -> void:
	var titlebar = get_titlebar_hbox()
	layer_label = Label.new()
	layer_label.text = ""
	layer_label.add_theme_color_override("font_color", Color("#7f7f7f"))
	titlebar.add_child(layer_label)

	var hbox = HBoxContainer.new()
	hbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	hbox.add_theme_constant_override("separation", 8)
	add_child(hbox)	

	name_field = TextEdit.new()
	name_field.placeholder_text = "Name"
	name_field.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_field.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	name_field.custom_minimum_size = Vector2(0, 30)
	hbox.add_child(name_field)
	
	var preview_button := _material_preview_button()
	var visible_icon := _get_editor_icon("GuiVisibilityVisible")
	var hidden_icon := _get_editor_icon("GuiVisibilityHidden")

	preview_button.button_pressed = preview_visible
	preview_button.icon = visible_icon if preview_visible else hidden_icon
	preview_button.toggled.connect(func(on: bool) -> void:
		preview_visible = on
		if on and preview_viewport == null:
			_build_material_preview()
		if material_preview:
			material_preview.visible = on
		if preview_viewport:
			preview_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS if on else SubViewport.UPDATE_DISABLED
		preview_button.icon = visible_icon if on else hidden_icon
		reset_size())

	hbox.add_child(preview_button)
	if preview_visible:
		_build_material_preview()
	if not preview_visible:
		reset_size()

	

	_apply_msdf_font()


func _build_material_preview() -> void:
	if preview_viewport != null:
		return
	var vp := SubViewport.new()
	vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	var world := World3D.new()
	world.environment = preview_environment
	vp.world_3d = world
	vp.transparent_bg = _is_transparent_bg_enabled()
	vp.size = _get_preview_size()
	vp.anisotropic_filtering_level = 2
	vp.texture_mipmap_bias = -0.3
	var pm := MeshInstance3D.new()
	pm.mesh = _get_sphere_mesh()
	if preview_material:
		pm.material_override = preview_material
	preview_instance = pm
	var cam := Camera3D.new()
	cam.position = Vector3(0.0, 0.0, 1.6)
	cam.fov = 40
	vp.add_child(pm)
	vp.add_child(cam)
	add_child(vp)
	preview_viewport = vp

	var preview := TextureRect.new()
	preview.expand_mode = TextureRect.EXPAND_FIT_HEIGHT
	preview.texture = vp.get_texture()
	preview.visible = preview_visible
	add_child(preview)
	material_preview = preview


func set_preview_material(material: Material) -> void:
	preview_material = material
	if preview_instance:
		preview_instance.material_override = preview_material


func set_preview_resolution(size: Vector2i) -> void:
	if preview_viewport:
		preview_viewport.size = size


func set_transparent_bg(enabled: bool) -> void:
	if preview_viewport:
		preview_viewport.transparent_bg = enabled


func _get_preview_size() -> Vector2i:
	return Vector2i(
		ProjectSettings.get_setting("material_layers/preview_resolution", 128),
		ProjectSettings.get_setting("material_layers/preview_resolution", 128))


func _is_transparent_bg_enabled() -> bool:
	return ProjectSettings.get_setting("material_layers/preview_transparent", false)

func _set_defaults() -> void:
	add_theme_constant_override("separation", 8)

	var panel = get_theme_stylebox("panel").duplicate()
	panel.content_margin_top = 12
	panel.content_margin_bottom = 12
	add_theme_stylebox_override("panel", panel)
	custom_minimum_size = Vector2(240, 0)


func _add_active_button() -> CheckBox:
	var eye_button := CheckBox.new()
	eye_button.toggle_mode = true
	eye_button.size_flags_horizontal = Control.SIZE_SHRINK_END
	return eye_button


func _add_eye_button() -> CheckBox:
	return _add_active_button()


func _material_preview_button() -> Button:
	var eye_button := Button.new()
	eye_button.toggle_mode = true
	eye_button.flat = true
	eye_button.expand_icon = true
	eye_button.custom_minimum_size = Vector2(24, 24)
	return eye_button


static var _editor_icons: Dictionary

static func _get_editor_icon(name: String) -> Texture2D:
	if not _editor_icons.has(name):
		var theme: Theme = EditorInterface.get_editor_theme()
		_editor_icons[name] = theme.get_icon(name, "EditorIcons") if theme else null
	return _editor_icons[name]

func get_port_type(is_output: bool, port: int) -> int:
	var list: Array = port_types["output" if is_output else "input"]
	return list[port] if port < list.size() else 0

static var _msdf_font: FontFile

static func _get_msdf_font() -> FontFile:
	if _msdf_font == null:
		var base: Font = EditorInterface.get_editor_theme().get_default_font()
		if base is FontVariation:
			base = (base as FontVariation).base_font
		if not base is FontFile:
			base = ThemeDB.get_fallback_font()
		if base is FontFile:
			_msdf_font = (base as FontFile).duplicate()
			_msdf_font.multichannel_signed_distance_field = true
			_msdf_font.clear_cache()
	return _msdf_font

func _apply_msdf_font() -> void:
	var font := _get_msdf_font()
	if font == null:
		return
	_apply_msdf_font_to(self, font)

func _apply_msdf_font_to(parent: Node, font: Font) -> void:
	for i in parent.get_child_count(true):
		var child := parent.get_child(i, true)
		if child is Label or child is TextEdit:
			child.add_theme_font_override("font", font)
		if child.get_child_count(true) > 0:
			_apply_msdf_font_to(child, font)

func set_layer_name(text: String) -> void:
	if name_field:
		name_field.text = text

func get_layer_name() -> String:
	return name_field.text if name_field else ""
