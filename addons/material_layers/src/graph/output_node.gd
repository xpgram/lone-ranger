@tool
class_name OutputNode
extends LayerGraphNode

signal save_requested

var save: Button

func _ready():
    super._set_defaults()

    title = " Output"
    tooltip_text = "Outputs result"

    var titlebar = get_titlebar_hbox()
    var icon_rect = TextureRect.new()
    icon_rect.texture = preload("res://addons/material_layers/icons/outputIcon.svg")
    icon_rect.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED

    titlebar.add_child(icon_rect)
    titlebar.move_child(icon_rect, 0)

    save = Button.new()
    save.text = "Save"
    save.custom_minimum_size = Vector2(0, 45)
    save.size_flags_vertical = Control.SIZE_EXPAND_FILL
    save.pressed.connect(func() -> void: save_requested.emit())

    var vbox = VBoxContainer.new()
    vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL

    vbox.add_child(save)

    add_child(vbox)

    port_types.input = [TYPE_BASE]

    set_slot(0, true, 0, PORT_COLOR, false, 0, PORT_COLOR, ICON_BASE)
    
    _apply_msdf_font()
