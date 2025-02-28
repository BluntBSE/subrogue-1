extends Node3D
class_name SignalObject

var faction #For visibility?
var detecting_object:Entity
var display_name:String
var time_ago:float #Last time this signal was updated
var detected_object:Entity
var certainty:float = 50.0
var hidden:bool
var last_sound:Sound
@onready var sprite = get_node("Sprite3D")
#Certainty of 100 is perfectly accurate.
#A certainty of (approaching) 0 is within 200km

func offset_self():
    var km_offset = lerp(200.0,0.0,max((certainty/100), 1.0 ) )
    #print("KM Offset calculated as ", km_offset, " with a certainty of ", certainty)
    var anchor: Planet = detecting_object.anchor
    
    # Calculate a random tangential direction
    var position_on_sphere = position
    var random_vector = Vector3(randf(), randf(), randf()).normalized()
    #flip the random vector half the time to allow negatives
    var rand = randf()
    if rand < 0.49:
        random_vector = -random_vector
    var new_direction = random_vector.cross(position_on_sphere).normalized()
    
    var new_position = position + (new_direction * GlobeHelpers.km_to_arc_distance(km_offset, anchor))
    position = new_position

func fix_height()->void:
    #The  entity should always be a height above the surface of the anchor.
    #If tne anchor has a radius of 100m, the entity shall sit at 100.25 (or GlobalConst.height), but not otherwise modify its position.
    #A higher height will be more permissive when colliding with the map
    var direction:Vector3 = (position - detecting_object.anchor.position).normalized()
    var desired_position:Vector3 = detecting_object.anchor.position + (direction * GlobalConst.height)
    position = desired_position
    pass
    

func unpack(_detecting_object:Entity, _detected_object:Entity, _sound:Sound, _certainty:float):
    sprite.set_layer_mask_value(_detecting_object.faction, true)
    for child in sprite.get_children():
        child.set_layer_mask_value(_detecting_object.faction,true)
    print("Unpack called with ", _detecting_object, _detected_object)
    last_sound = _sound
    certainty = _certainty
    detected_object = _detected_object
    detecting_object = _detecting_object
    position = _detected_object.position
    offset_self()
    #fix_height()
    

var elapsed = 0.0
func _process(delta:float)->void:
    var timer = 2.0
    elapsed += delta
    if elapsed >= timer:
        position = detected_object.position
        offset_self()
        elapsed = 0.0
    pass
