extends Label
class_name SelfInspectUpgradeLabel
@export var inspection_root:SelfMenuRoot
@export var upgrade_root:SelfInspectionUpgradeRoot
@export var upgrade:Upgrade
signal hovered_upgrade

func _ready():
    mouse_entered.connect(_on_mouse_entered)
    hovered_upgrade.connect(upgrade_root.handle_hovered_upgrade)
    pass


func _on_mouse_entered() -> void:
    print("Merp from ", name)
    hovered_upgrade.emit(self)
    pass # Replace with function body.
