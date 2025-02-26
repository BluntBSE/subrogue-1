extends Node3D
class_name EntityDetector

#Passive detection stats
@onready var detection_area = %DetectionArea
var sensitivity:float = 20.0 #Expressed as minimum DB to hear
var c100:float = 300.0 #Expressed as km
var cfalloff:float = 1.0 #Certainty lost per 10km.
var min_certainty: float = 20.0 #Always at least 20% certain in detection position
var max_range:float = 2000.0 #Expressed as km

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass
