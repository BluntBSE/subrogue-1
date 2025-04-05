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
var anchor:Planet
var lerping = false #For animation
#Certainty of 100 is perfectly accurate.
#A certainty of (approaching) 0 is within 200km

func offset_self():
    #Used for appearing in a random location when first detected.
    var km_offset = lerp(200.0,0.0,(certainty/100) )
    #print("KM Offset calculated as ", km_offset, " with a certainty of ", certainty)
    anchor = detecting_object.anchor
    
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
    var vecfloat = GlobeHelpers.km_to_arc_distance(km_offset, anchor) * 2.0
    %CertaintyRadius.scale = Vector3(vecfloat, vecfloat, vecfloat)
   # print("km_offset is ", km_offset)
   # print("scale is ", vecfloat)
   # print("Certainty is ", certainty)
    %CertaintyLabel.text = str( snapped(certainty, 1) ) + "%"
    look_at(anchor.position)
    
func new_offset_position()->Vector3:
    #After the initial detection, this is used to determine where the signal ought to lerp to
    var km_offset = lerp(200.0,0.0,(certainty/100) )
    #print("KM Offset calculated as ", km_offset, " with a certainty of ", certainty)
    anchor = detecting_object.anchor
    
    # Calculate a random tangential direction
    var position_on_sphere = detected_object.position
    var random_vector = Vector3(randf(), randf(), randf()).normalized()
    #flip the random vector half the time to allow negatives
    var rand = randf()
    if rand < 0.49:
        random_vector = -random_vector
    var new_direction = random_vector.cross(position_on_sphere).normalized()
    
    var new_position = detected_object.position + (new_direction * GlobeHelpers.km_to_arc_distance(km_offset, anchor))
    return new_position

func new_certainty_scale()->Vector3:
    anchor = detecting_object.anchor
    var km_offset = lerp(200.0,0.0,(certainty/100) )
    var vecfloat = GlobeHelpers.km_to_arc_distance(km_offset, anchor) * 2.0
    return clamp(Vector3(vecfloat, vecfloat, vecfloat), Vector3(3.0,3.0,3.0), Vector3(15.0,15.0,15.0))
   
 
    

func fix_height()->void:
    #The  entity should always be a height above the surface of the anchor.
    #If tne anchor has a radius of 100m, the entity shall sit at 100.25 (or GlobalConst.height), but not otherwise modify its position.
    #A higher height will be more permissive when colliding with the map
    var direction:Vector3 = (position - detecting_object.anchor.position).normalized()
    var desired_position:Vector3 = detecting_object.anchor.position + (direction * GlobalConst.height)
    position = desired_position
    pass
    

func unpack(_detecting_object:Entity, _detected_object:Entity, _sound:Sound, _certainty:float):
    var sprite = get_node("Sprite3D")
    sprite.set_layer_mask_value(_detecting_object.faction, true)
    for child in sprite.get_children():
        child.set_layer_mask_value(_detecting_object.faction,true)
    for child in %CertaintyRadius.get_children():
        child.set_layer_mask_value(_detecting_object.faction,true)
    print("Unpack called with ", _detecting_object, _detected_object)
    last_sound = _sound
    certainty = _certainty
    detected_object = _detected_object
    detecting_object = _detecting_object
    position = _detected_object.position
    offset_self()
    #fix_height()

func turn_red():
    
    var sprite:Sprite3D = get_node("Sprite3D")
    sprite.modulate = Color("#ff0000")
func tween_to_new():
    var new_position = new_offset_position()
    var new_scale = new_certainty_scale()
    var tween = get_tree().create_tween()
    tween.set_parallel(true)
    #Currently this tween timing is equal to the polling rate. Consider making it longer than polling rate for more ucnertainty
    tween.tween_property(%CertaintyRadius, "scale",new_scale, 2.0)
    tween.tween_property(self, "position", new_position, 2.0)
    %CertaintyLabel.text = str(  snapped(certainty, 1)  ) + "%"
    
    %CertaintyRadius.scale= clamp(%CertaintyRadius.scale, Vector3(3.0,3.0,3.0), Vector3(30.0,30.0,30.0))

    
    

var elapsed = 0.0
var tween_progress = 0.0
var tween_speed= 1.0
func _process(delta:float)->void:
    if lerping == true:
        tween_progress += delta * tween_speed
    position += detected_object.linear_velocity /60 #Can we do this to actual engine frames? 60 is right if we're running at ideal speed but we might not be
    look_at(anchor.position)
    pass
