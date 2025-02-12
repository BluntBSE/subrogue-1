extends Node3D
class_name Player

var entities:Node3D
@onready var markers:PlayerMarkers = get_node("PlayerMarkers")

@onready var selected = [%PlayerEntity] #Selection is not a feature of the game for now.

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass
    
