extends EntityController
class_name PlayerEntities

var camera:OrbitalCamera


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    
    #relay move commands to their destination
    camera = %OrbitalCamera
    camera.order_move.connect(relay_order_move)
    camera.enqueue_move.connect(relay_enqueue_move)
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass
