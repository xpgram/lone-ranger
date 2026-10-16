@tool
class_name MaskNode
extends LayerGraphNode

@export var mask : MaskMaterial

func _ready():
    super._ready()
    super._set_defaults()

    title = " Mask"
    tooltip_text = "Contains MaskMaterial"

    if mask == null:
        mask = MaskMaterial.new()

    var titlebar = get_titlebar_hbox()
    var icon_rect = TextureRect.new()
    icon_rect.texture = preload("res://addons/material_layers/icons/maskMaterial.svg")
    icon_rect.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED

    titlebar.add_child(icon_rect)
    titlebar.move_child(icon_rect, 0) # Moves it to the very left of the title

    var blend_label = Label.new()
    blend_label.text = "Blend"
    blend_label.custom_minimum_size = Vector2(0, 34)
    add_child(blend_label)
    move_child(blend_label, 0)

    var base_label = Label.new()
    base_label.text = "Base"
    base_label.custom_minimum_size = Vector2(0, 34)
    add_child(base_label)
    move_child(base_label, 1)

    name_field.text = mask.resource_path.get_file().get_basename()

    port_types.input = [TYPE_BLEND, TYPE_BOTH]
    port_types.output = [TYPE_BASE]

    set_slot(0, true, 0, PORT_COLOR, false, 0, PORT_COLOR, ICON_BLEND)
    set_slot(1, true, 0, PORT_COLOR, true, 0, PORT_COLOR, ICON_BOTH, ICON_BASE)

