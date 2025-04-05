extends Node3D
class_name EntityDebug

signal debug_message

func dmsg(string:String)->void:
    debug_message.emit(string)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass
