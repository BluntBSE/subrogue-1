extends Node3D

@export var pitch:float = 90.0 #Expressed as hz.
@export var profile:float = 70.0 #Arbitrary 0-100 scale of "how much this object resembles a military target". Values over 95 are almost certainly torpedoes."
@export var volume:float = 110.0 #Expressed as DB. 
#The above defaults represent the sonic profile of the Russian Akula
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass
