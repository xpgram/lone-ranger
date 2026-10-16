@tool
extends EditorPlugin

var _layer_stack_inspector_plugin: LayerStackInspectorPlugin
var _graph_inspector_plugin: LayerGraphInspectorPlugin

var graph_editor_scene = preload("res://addons/material_layers/src/graph/scenes/layer_graph.tscn")
var graph_editor_instance

func _enter_tree() -> void:
    ProjectSettings.set_initial_value("material_layers/preview_transparent", false)
    ProjectSettings.set_initial_value("material_layers/preview_resolution", 256)

    graph_editor_instance = graph_editor_scene.instantiate()
    add_control_to_bottom_panel(graph_editor_instance, "Layer Graph")
    
    _layer_stack_inspector_plugin = LayerStackInspectorPlugin.new()
    add_inspector_plugin(_layer_stack_inspector_plugin)

    _graph_inspector_plugin = LayerGraphInspectorPlugin.new()
    _graph_inspector_plugin.plugin = self
    _graph_inspector_plugin.panel = graph_editor_instance
    _graph_inspector_plugin.graph_edit = graph_editor_instance.get_node("HSplitContainer/GraphEdit")
    add_inspector_plugin(_graph_inspector_plugin)


func _exit_tree() -> void:
    remove_control_from_bottom_panel(graph_editor_instance)
    graph_editor_instance.queue_free()
    
    remove_inspector_plugin(_graph_inspector_plugin)
    _graph_inspector_plugin = null

    remove_inspector_plugin(_layer_stack_inspector_plugin)
    _layer_stack_inspector_plugin = null