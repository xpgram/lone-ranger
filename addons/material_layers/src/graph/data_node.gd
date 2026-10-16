@tool
class_name DataNode
extends LayerGraphNode

@export var data : DataMaterial

func _ready():
    super._ready()
    super._set_defaults()

    title = " Data"
    tooltip_text = "Contains DataMaterial"

    if data == null:
        data = DataMaterial.new()

    var titlebar = get_titlebar_hbox()
    var icon_rect = TextureRect.new()
    icon_rect.texture = preload("res://addons/material_layers/icons/dataMaterial.svg")
    icon_rect.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED


    titlebar.add_child(icon_rect)
    titlebar.move_child(icon_rect, 0)
    
    name_field.text = data.resource_path.get_file().get_basename()

    port_types.input = [TYPE_BOTH]
    port_types.output = [TYPE_BASE]

    set_slot(0, true, 0, PORT_COLOR, true, 0, PORT_COLOR, ICON_BOTH, ICON_BASE)
    
   
