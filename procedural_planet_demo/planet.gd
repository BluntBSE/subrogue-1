@tool
extends Node3D
class_name ProceduralPlanet

func _ready()->void:
    print("Good morning from procedural planet")
    var children = get_children()
    for child:PlanetMeshFace in children:
        child.regenerate_mesh()
