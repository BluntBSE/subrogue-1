@tool
extends Node3D
@export var pulse:bool = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    send_pulse()
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
"""

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
    if pulse == true:
        %SonarPulseMesh.material_override.set_shader_parameter("frontier_head", 0.05)
        %SonarPulseMesh.material_override.set_shader_parameter("frontier_tail", 0.0)
        send_pulse()
        pulse = false
    pass
    #send_pulse()

func send_pulse():
    var tween:Tween = get_tree().create_tween().set_trans(Tween.TRANS_EXPO).set_parallel(true).set_loops(5).set_ease(1)
    tween.tween_property(%SonarPulseMesh, "material_override:shader_parameter/frontier_head", 1.0, 2.0).from_current()
    tween.tween_property(%SonarPulseMesh, "material_override:shader_parameter/frontier_tail", 0.95, 2.0).from_current()
    
