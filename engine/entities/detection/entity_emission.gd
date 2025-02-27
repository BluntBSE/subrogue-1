extends Node3D

@onready var entity:Entity = get_parent()
@export var pitch:float = 90.0 #Expressed as hz.
@export var profile:float = 70.0 #Arbitrary 0-100 scale of "how much this object resembles a military target". Values over 95 are almost certainly torpedoes."
@export var volume:float = 110.0 #Expressed as DB. 
@export var speed_volume:float = 20.0 #Expressed as DB above baseline full speed will add.
#The above defaults represent the sonic profile of the Russian Akula
signal sound #Emits a volume, pitch

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    
    var total_volume = volume + lerp(0.0,speed_volume,(entity.speed/entity.max_speed))
    
    var sound_obj = Sound.new(entity, pitch, total_volume, profile)
    sound.emit(sound_obj)
    pass
