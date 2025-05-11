extends Label
class_name SelfInspectUpgradeLabel
@export var inspection_root:SelfMenuRoot
#var upgrade:Upgrade
signal hovered_upgrade

func _ready():
    pass


func _on_mouse_entered() -> void:
    hovered_upgrade.emit(self)
    pass # Replace with function body.
