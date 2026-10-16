@tool
class_name SurfaceNode
extends LayerGraphNode

@export var surface : SurfaceMaterial

func _ready():
    super._ready()
    super._set_defaults()
    
    title = " Surface"
    tooltip_text = "Contains SurfaceMaterial"

    if surface == null:
        surface = SurfaceMaterial.new()

    var titlebar = get_titlebar_hbox()
    var icon_rect = TextureRect.new()
    icon_rect.texture = preload("res://addons/material_layers/icons/surfaceMaterial.svg")
    icon_rect.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED


    titlebar.add_child(icon_rect)
    titlebar.move_child(icon_rect, 0) # Moves it to the very left of the title

    name_field.text = surface.resource_path.get_file().get_basename()
    
    port_types.input = [TYPE_BASE]
    port_types.output = [TYPE_BLEND]

    set_slot(0, true, 0, PORT_COLOR, true, 0, PORT_COLOR, ICON_BASE, ICON_BLEND)
