extends Node
class_name UIHelpers

static func recursively_modulate_controls(node:Node, modulation:Color, type="Control"):
    for child in node.get_children():
        if child.is_class(type):
            child as Control
            child.modulate = modulation
        recursively_modulate_controls(child, modulation)
