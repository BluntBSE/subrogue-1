extends Node3D
class_name PlayerMarkers
var player:Player
var camera
var context_markers := []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    pass # Replace with function body.

func unpack():
    player = get_parent()
    camera = player.get_node("PlayerCameras/OrbitalCamera")
    camera.close_context.connect(handle_close_context)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass
    
func add_marker(marker:Node3D):
    if marker is ContextMarker:
        context_markers.append(marker)
    add_child(marker)

func handle_close_context()->void:
    clear_contexts()
        
func clear_contexts()->void:
     for marker in context_markers:
        context_markers.erase(marker)
        marker.queue_free()           

func handle_launch(_args:Dictionary)->void:
    #Concerned with WHICH context menu launched, this only handles closing it.
    clear_contexts()
    pass
            
