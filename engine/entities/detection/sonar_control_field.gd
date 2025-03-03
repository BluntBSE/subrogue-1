@tool
extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
var frontier_delta = 0.0
var speed = 2.0
func _process(delta: float) -> void:
    frontier_delta += delta * speed
    var frontier_head = fmod(frontier_delta, PI) / PI #I don't actually understand why we do this part.
    print("Frontier head: ", frontier_head)
    var frontier_tail = frontier_head - 0.05
    %SonarMesh.material_override.set_shader_parameter("frontier_head", frontier_head)
    %SonarMesh.material_override.set_shader_parameter("frontier_tail", frontier_tail)

    pass
