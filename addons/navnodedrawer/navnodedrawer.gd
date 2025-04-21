@tool
extends EditorPlugin
var dock: NavNodeDrawerDock

func _enter_tree() -> void:
    # Initialization of the plugin goes here.
    dock = preload("res://addons/navnodedrawer/navnodedock.tscn").instantiate()
    add_control_to_dock(EditorPlugin.DOCK_SLOT_LEFT_BL, dock)
    pass


func _exit_tree() -> void:
    # Clean-up of the plugin goes here.
    pass
