@tool
extends Control
class_name NavNodeDrawerDock

func _enter_tree() -> void:
    pass

func _input(event: InputEvent) -> void:
    if InputMap.has_action("editor_apply_to") and Input.is_action_just_pressed("editor_apply_to"):
        print("Foo!")
