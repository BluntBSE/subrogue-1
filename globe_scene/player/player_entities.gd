extends EntityController
class_name PlayerEntities
#Like entity controller, but it's hooked up to the camera!
var camera:OrbitalCamera


# Called when the node enters the scene tree for the first time.
func _ready() -> void:

    
    pass # Replace with function body.

func unpack():
    player = get_parent()
    camera = player.get_node("PlayerCameras/OrbitalCamera")
    camera.order_move.connect(relay_order_move)
    camera.enqueue_move.connect(relay_enqueue_move)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass
