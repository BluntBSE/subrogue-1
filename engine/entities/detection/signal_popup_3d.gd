extends Node3D
class_name SignalPopup

####SIGNAL DATA ITSELF####
var faction #For visibility?
var detecting_object:Entity
var display_name:String
var time_ago:float #Last time this signal was updated
var detected_object:Entity
var certainty:float = 50.0
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

var update_threshold:float #Distance that either entity must be crossed by either entity before triggering an update
#Checks the distance between these two values with GlobeHelpers game to km
var last_detector_position:Vector3
var last_detected_position:Vector3
var offset:Vector3

#CONTEXT ARGS
var originating_entities:Array #For now this is exclusively the one entity under the player's control.
var player:Node3D
var over_entity:Node3D #If the player dropped this over an entity, it must track the entity and also allow hailing
#var line_to #Possibly give this node ownerhsip over the line
func unpack(_detecting_object:Entity, _detected_object:Entity, _sound, _certainty):
    print("Signal popup unpack")
    detecting_object = _detecting_object
    position = _detected_object.position
    initial_position = position
    target_position = position
    print("Called signal object unpack! DO was", _detected_object)
    anchor = detecting_object.anchor
    sound = _sound
    detected_object = _detected_object

    # Calculate the offset once and store it
    offset = calculate_offset()
    
    # Register self with player and its marker observer
    set_process(true)
    unpacked = true

func _ready():
    print("Signal popup has entered the scene tree")
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
    target_position = detected_object.position + offset

    # Adjust height, scale, and rotation
    adjust_height()
    scale_with_camera_distance()
    rotate_area_to_anchor()


func add_random_offset():
    if not anchor or not detected_object:
        return

    # Calculate the offset distance based on certainty
    var km_offset = lerp(900.0, 0.0, certainty / 100.0)

    # Get the position on the sphere
    var position_on_sphere = detected_object.global_position.normalized()

    # Generate a random vector
    var random_vector = Vector3(randf(), randf(), randf()).normalized()

    # Ensure the random vector is perpendicular to the sphere's surface
    var tangential_direction = random_vector.cross(position_on_sphere).normalized()

    # Calculate the offset position
    var offset_distance = GlobeHelpers.km_to_arc_distance(km_offset, anchor)
    var offset_position = tangential_direction * offset_distance

    # Apply the offset to the target position
    target_position += offset_position

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

func adjust_height()->void:
    #Move to surface of sphere relative to the camera
    var camera = get_viewport().get_camera_3d()
    var direction_to_camera: Vector3 = (camera.global_transform.origin - node_quad.global_transform.origin).normalized()
    var factor:float = abs((target_position.y / 10.0)) + 1.0
    position = lerp(target_position, target_position + (direction_to_camera * hover_height), factor)
    


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


func calculate_update_threshold():
    pass

func check_for_updates():
    var diff:Vector3 = last_detected_position-last_detector_position
    var dist:float = diff.length()
    if dist > update_threshold:
        #Do update
        pass
    pass
