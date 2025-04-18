extends Node3D
class_name SignalPopup

####SIGNAL DATA ITSELF####
var positively_identified:bool = false
var signal_id = "Roma-97"
var color:Color = Color("ffffff")
var faction #For visibility?
var detecting_object:Entity
var display_name:String
var time_ago:float #Last time this signal was updated
var detected_object:Entity
var certainty:float = 50.0:
    set(value):
        certainty = value
        update_threshold = calculate_update_threshold()
var hidden:bool
var sound:Sound
var last_sound:Sound
var lerping = false #For animation

#unpacked
var unpacked:bool = false




####3D VARIABLES####
# Used for checking if the mouse is inside the Area3D.
var is_mouse_inside = false
# The last processed input touch/mouse event. To calculate relative movement.
var last_event_pos2D = null
# The time of the last event in seconds since engine start.
var last_event_time: float = -1.0

@export var node_viewport:SubViewport
@export var node_quad:MeshInstance3D
@export var node_area:Area3D #Should have a collisionshape under it that matches the meshInstance3D
#Generate it from the Mesh button at the top of the editor while mesh is selected

var anchor:Node3D
var initial_position:Vector3
var target_position:Vector3
var hover_height := 2.0 #If we are south of the equator, ke

var needs_update:bool = false
var update_threshold:float #Distance in game KM that either entity must be crossed by either entity before triggering an update
#Checks the distance between these two values with GlobeHelpers game to km
var last_detector_position:Vector3
var last_detected_position:Vector3
var offset:Vector3
var last_velocity:Vector3

#CONTEXT ARGS
var originating_entities:Array #For now this is exclusively the one entity under the player's control.
var player:Node3D
var over_entity:Node3D #If the player dropped this over an entity, it must track the entity and also allow hailing
#var line_to #Possibly give this node ownerhsip over the line

#SIGNALS
signal opened
signal closed
signal stream
signal stream_color

func disable():
    #TODO unhook any signals here
    visible = false
    set_process(false)

func unpack(_detecting_object:Entity, _detected_object:Entity, _sound, _certainty):
    visible = true
    detecting_object = _detecting_object
    position = _detected_object.position
    initial_position = position
    target_position = position
    anchor = detecting_object.anchor
    sound = _sound
    detected_object = _detected_object
    if detecting_object.is_player:
        #TODO: Disconnect and connect all these signals as something fades in and out of view.
        player = detecting_object.played_by
        opened.connect(player.UI.handle_opened_signal)
        player.UI.edited_signal_name.connect(handle_update_name)
        player.UI.edited_color.connect(handle_update_color)
        stream_color.connect(player.UI.handle_color_stream)
    
    #Signals
    #TODO: If they're already connected, don't do it again.
    detected_object.died.connect(handle_detected_object_died)
    detecting_object.died.connect(handle_detecting_object_died)
    # Calculate the offset once and store it
    offset = calculate_offset()
    #How far must the entities travel before updating again?
    update_threshold = calculate_update_threshold()
    GlobeHelpers.recursively_update_visibility(self, 1, false)
    GlobeHelpers.recursively_update_visibility(self, detecting_object.faction, true)
    set_process(true)
    needs_update = false
    unpacked = true
    

func _ready():
    node_area.mouse_entered.connect(_mouse_entered_area)
    node_area.mouse_exited.connect(_mouse_exited_area)
    node_area.input_event.connect(_mouse_input_event)
    set_process(false)

 
        
func calculate_offset() -> Vector3:
    if not anchor or not detected_object:
        return Vector3.ZERO

    # Calculate the offset distance based on certainty
    var km_offset = lerp(400.0, 0.0, certainty / 100.0)

    # Get the position on the sphere
    var position_on_sphere = detected_object.global_position.normalized()

    # Generate a random vector
    var random_vector = Vector3(randf(), randf(), randf()).normalized()

    # Ensure the random vector is perpendicular to the sphere's surface
    var tangential_direction = random_vector.cross(position_on_sphere).normalized()

    # Calculate the offset position
    var offset_distance = GlobeHelpers.km_to_arc_distance(km_offset, anchor)
    return tangential_direction * offset_distance
    
func match_detected_velocity():
    if detected_object:  # Ensure the detected object exists
        # Get the detected object's velocity
        target_position += detected_object.linear_velocity/60
     
func _process(_delta):
    # Update the target position to the detected object's position with the precomputed offset
    position = lerp(position, target_position, _delta)
    # Move to target position
    scale_with_camera_distance()
    rotate_area_to_anchor()
    check_update_necessary()
    update_if_needed()
    
    if last_velocity:
        position += last_velocity / 60
    print("EMITTING ", color)
    stream_color.emit(color)   



func _mouse_entered_area():
    is_mouse_inside = true


func _mouse_exited_area():
    is_mouse_inside = false



func _unhandled_input(event):
    # Check if the event is a non-mouse/non-touch event
    for mouse_event in [InputEventMouseButton, InputEventMouseMotion, InputEventScreenDrag, InputEventScreenTouch]:
        if is_instance_of(event, mouse_event):
            # If the event is a mouse/touch event, then we can ignore it here, because it will be
            # handled via Physics Picking.
            return
    node_viewport.push_input(event)
    
    



func _mouse_input_event(_camera: Camera3D, event: InputEvent, event_position: Vector3, _normal: Vector3, _shape_idx: int):
    # Get mesh size to detect edges and make conversions. This code only support PlaneMesh and QuadMesh.
    var quad_mesh_size = node_quad.mesh.size

    # Event position in Area3D in world coordinate space.
    var event_pos3D = event_position

    # Current time in seconds since engine start.
    var now: float = Time.get_ticks_msec() / 1000.0

    # Convert position to a coordinate space relative to the Area3D node.
    # NOTE: affine_inverse accounts for the Area3D node's scale, rotation, and position in the scene!
    event_pos3D = node_quad.global_transform.affine_inverse() * event_pos3D

    # TODO: Adapt to bilboard mode or avoid completely.

    var event_pos2D: Vector2 = Vector2()

    if is_mouse_inside:
        # Convert the relative event position from 3D to 2D.
        event_pos2D = Vector2(event_pos3D.x, -event_pos3D.y)

        # Right now the event position's range is the following: (-quad_size/2) -> (quad_size/2)
        # We need to convert it into the following range: -0.5 -> 0.5
        event_pos2D.x = event_pos2D.x / quad_mesh_size.x
        event_pos2D.y = event_pos2D.y / quad_mesh_size.y
        # Then we need to convert it into the following range: 0 -> 1
        event_pos2D.x += 0.5
        event_pos2D.y += 0.5

        # Finally, we convert the position to the following range: 0 -> viewport.size
        event_pos2D.x *= node_viewport.size.x
        event_pos2D.y *= node_viewport.size.y
        # We need to do these conversions so the event's position is in the viewport's coordinate system.

    elif last_event_pos2D != null:
        # Fall back to the last known event position.
        event_pos2D = last_event_pos2D

    # Set the event's position and global position.
    event.position = event_pos2D
    if event is InputEventMouse:
        event.global_position = event_pos2D

    # Calculate the relative event distance.
    if event is InputEventMouseMotion or event is InputEventScreenDrag:
        # If there is not a stored previous position, then we'll assume there is no relative motion.
        if last_event_pos2D == null:
            event.relative = Vector2(0, 0)
        # If there is a stored previous position, then we'll calculate the relative position by subtracting
        # the previous position from the new position. This will give us the distance the event traveled from prev_pos.
        else:
            event.relative = event_pos2D - last_event_pos2D
            event.velocity = event.relative / (now - last_event_time)

    # Update last_event_pos2D with the position we just calculated.
    last_event_pos2D = event_pos2D

    # Update last_event_time to current time.
    last_event_time = now

    # Finally, send the processed input event to the viewport.
    node_viewport.push_input(event)



func rotate_area_to_anchor():
    var camera = get_viewport().get_camera_3d()
    var direction_to_anchor:Vector3 = (camera.global_transform.origin - anchor.global_transform.origin).normalized()
    var camera_up = camera.global_transform.basis.y
    node_quad.look_at(anchor.global_transform.origin, camera_up, false)
    rotation.y = 90.0
    pass
  
func scale_with_camera_distance():
    #Base parameters: at 200 distance, scale of 1.0.
    #At 1000 distance, scale of 3.0
    var camera = get_viewport().get_camera_3d()
    var distance = camera.global_position - global_position
    var ratio = inverse_lerp(30, 300, distance.length())
    var sf = lerp(0.2,1.8, ratio)
    sf = clamp(sf, 0.2,2.5)
    scale = Vector3(sf,sf,sf)


func calculate_update_threshold()->float:
    #How far can the distance between the entities change before an update is necessary?
    #Let's say at certainty 20, you must have 500km of change. At certainty 99, you must travel only 50km
    var factor = inverse_lerp(10.0, 100.0, certainty)
    var threshold = lerp(300.0, 25.0, factor)
    return threshold


func check_update_necessary()->void:
    #If either entity has died, this is not necessary.
    if detected_object == null or detecting_object == null:
        return
    var last_dist_km = GlobeHelpers.arc_to_km(last_detected_position, last_detector_position, anchor)
    var cur_dist_km = GlobeHelpers.arc_to_km(detected_object.global_position, detecting_object.global_position, anchor)
    var dist_diff = abs(last_dist_km - cur_dist_km)
    #print("dist diff: ", dist_diff, " vs ", update_threshold)
    if dist_diff > update_threshold:
        needs_update = true


var last_update_time: float = 0.0  # Time of the last update
var update_interval: float = 0.5  # Minimum interval between updates (in seconds)
func update_if_needed() -> void:
    var current_time = Time.get_ticks_msec() * 1000  # Get the current time in seconds
    if needs_update and (current_time - last_update_time >= update_interval):
        print("Update for signal popup was called!")
        last_detected_position = detected_object.global_position
        last_detector_position = detecting_object.global_position
        update_threshold = calculate_update_threshold()
        
        # Move to a new random offset based on certainty
        offset = calculate_offset()
        needs_update = false
        target_position = detected_object.position + offset

        # Update the last update time
        last_update_time = current_time
        last_velocity = detected_object.linear_velocity
        modulate_by_certainty()
        stream.emit({"volume":sound.volume, "pitch":sound.pitch, "certainty":certainty})

    
func handle_detected_object_died(_entity:Entity):
    queue_free()
    pass

func handle_detecting_object_died(_entity:Entity):
    #Actually maybe it's notj ust a queue_free here because there may be other objects detecting the same object, and we need
    #To reassign
    queue_free()
    #This will also involve updating last_detected_position if necessary, maybe handled by "do_update"
    pass

func modulate_by_certainty():
    var control:Control = %SignalControlScene
    var uncertain_color = Color("262626")
    var certain_color = Color("ffffff")
    var factor = inverse_lerp(10.0, 100.0, certainty)
    var final_color = lerp(uncertain_color, certain_color, factor)
    control.modulate = final_color



#TODO:
#Make visible only to dector
#Handle when detected destroyed
#Handle when detector destroyed
#Update offset as a function of time (engine or game time?) * certainty
#Fade colors (and size?) as a function of certainty
#Once size is implemented, modify size as a function of size.
#Once depth is implemented, modify sprite as a function of depth


func _on_area_3d_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
    #print("Got an input event")
    #if event is InputEventMouse:
    if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_released():
        print("Got a LEFT CLICK on the signal event")
        opened.emit(self)
    pass # Replace with function body.


func _on_area_3d_mouse_entered() -> void:
    var hover_modulator = find_child("HoverModulator", true, false)
    hover_modulator.modulate = Color("00aea8")
    pass # Replace with function body.


func _on_area_3d_mouse_exited() -> void:
    var hover_modulator = find_child("HoverModulator", true, false)
    hover_modulator.modulate = Color("ffffff")
    
    pass # Replace with function body.

func handle_update_name(str:String):
    if positively_identified == false:
        signal_id = str
        var id_label:Label = find_child("SignalID", true, false)
        id_label.text = signal_id
        
func handle_update_color(_color:Color):
    %SignalControlScene.get_node("AssignedColorModulator").modulate = _color
    color = _color
    
