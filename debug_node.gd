extends Node
class_name DebugNode

@export var flag_log_fps:bool = false
var fps_poll_timer := 1.0
var fps_timer := 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    if flag_log_fps == true:
        log_fps(delta)

func log_fps(delta:float)->void:
    fps_timer += delta
    if fps_timer > fps_poll_timer:
        fps_timer = 0.0
        print("fps: " + str(Engine.get_frames_per_second()))	
