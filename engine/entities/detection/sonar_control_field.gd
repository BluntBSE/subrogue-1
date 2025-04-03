extends Node3D
class_name SonarNode
@export var pulse:bool = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    #send_pulse()
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
"""
Mathemetically based pulse example. Probably not going to use.

var frontier_delta = 0.0
var speed = 2.0
func _process(delta: float) -> void:
    frontier_delta += delta * speed
    var frontier_head = fmod(frontier_delta, PI) / PI #I don't actually understand why we do this part.
    print("Frontier head: ", frontier_head)
    var frontier_tail = frontier_head - 0.05
    %SonarPulseMesh.material_override.set_shader_parameter("frontier_head", frontier_head)
    %SonarPulseMesh.material_override.set_shader_parameter("frontier_tail", frontier_tail)

    pass
"""
func _process(delta:float)->void:
    var mesh_1:MeshInstance3D = %SonarPulseMesh
    var entity:Entity = get_parent()
    var up = (entity.anchor.position - entity.position).normalized()
    #This, along wth the funky rotations on the mesh, are how we keep the plane from clipping into the planet.
    mesh_1.look_at(entity.anchor.position)
    mesh_1.rotation.z += deg_to_rad(90.0)

    if pulse == true:

        #send_pulse()
        pulse = false
    pass
    #send_pulse()

func send_pulse():
    %SonarPulseMesh.material_override.next_pass.set_shader_parameter("frontier_head", 0.0)
    %SonarPulseMesh.material_override.next_pass.set_shader_parameter("frontier_tail", 0.0)
    var max = %SonarPulseMesh.material_override.get_shader_parameter("frontier_head")
    var tween:Tween = get_tree().create_tween().set_trans(Tween.TRANS_QUINT).set_ease(1)
    tween.tween_property(%SonarPulseMesh, "material_override:next_pass:shader_parameter/frontier_head", max, 1.0).from_current()
    tween.set_trans(Tween.TRANS_CIRC)
    tween.tween_property(%SonarPulseMesh, "material_override:next_pass:shader_parameter/frontier_tail", max, 0.5).from_current()
    
func handle_angle_1(angle):
    print("Handle angle 1 received ", angle)
    #BG
    %SonarPulseMesh.material_override.set_shader_parameter("start_angle", angle)
    #Foreground
    %SonarPulseMesh.material_override.next_pass.set_shader_parameter("start_angle", angle)

func handle_angle_2(angle):
    print("Handle angle 2 received ", angle)
    %SonarPulseMesh.material_override.set_shader_parameter("end_angle", angle)
    #Foreground
    %SonarPulseMesh.material_override.next_pass.set_shader_parameter("end_angle", angle)
    pass    

func handle_volume(dict:Dictionary):
    print("Handle volume called with ", dict)
    %SonarPulseMesh.material_override.set_shader_parameter("frontier_head", dict.max)

func handle_ping_request(_angle_1, _angle_2)->void:
    
    print("Ping requested")
    send_pulse()
