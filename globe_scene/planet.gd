extends MeshInstance3D
class_name Planet

@onready var camera:Camera3D = %OrbitalCamera
var raycast_origin:Vector3
var raycast_end:Vector3
var hovered_over := false
var hovered_point:Vector3

var foo = Mesh.ARRAY_MAX
var Packed:PackedVector3Array # PackedVector3Array
var uv: PackedVector2Array 
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:    
    #input
    handle_input()
    
    
func handle_input():
    #TODO, and SOON - switch with is_action_pressed for remapping
        pass
