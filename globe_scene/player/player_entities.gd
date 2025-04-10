extends EntityController
class_name PlayerEntities
#Like entity controller, but it's hooked up to the camera!
@onready var camera:OrbitalCamera = player.get_node("PlayerCameras/OrbitalCamera")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    camera.order_move.connect(relay_order_move)
    camera.enqueue_move.connect(relay_enqueue_move)
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass
