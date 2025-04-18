extends Node3D
class_name SignalPopup

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


#CONTEXT ARGS
var originating_entities:Array #For now this is exclusively the one entity under the player's control.
var player:Node3D
var over_entity:Node3D #If the player dropped this over an entity, it must track the entity and also allow hailing
#var line_to #Possibly give this node ownerhsip over the line

func unpack(_player:Player, _anchor):
    anchor = _anchor
    #Register self with player and its marker observer
    player = _player
    originating_entities = [player.entities.find_child("PlayerEntity", true, false)] #For now, the player only has the one entity the whole game.
   # %DistDisplay.text = str(get_distance_in_km()) + " km"   

func _ready():
    print("Signal popup has entered the scene tree")
    initial_position = position
    target_position = position
    node_area.mouse_entered.connect(_mouse_entered_area)
    node_area.mouse_exited.connect(_mouse_exited_area)
    node_area.input_event.connect(_mouse_input_event)

 
        



var update_timer:float = 0.0 #How often does the dist display update?
func _process(_delta):
    rotate_area_to_billboard()
    adjust_height()
    scale_with_camera_distance()
    
    update_timer += _delta
    if update_timer > 0.5:
        #%DistDisplay.text = str(get_distance_in_km()) + " km"
        update_timer = 0.0



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
    var camera = get_viewport().get_camera_3d()
    var direction_to_camera: Vector3 = (camera.global_transform.origin - node_quad.global_transform.origin).normalized()
    var factor:float = abs((target_position.y / 10.0)) + 1.0
    position = lerp(target_position, target_position + (direction_to_camera * hover_height), factor)
    
func rotate_area_to_billboard_backup():
    
    var camera = get_viewport().get_camera_3d()
    #var mouse = get_viewport().get_mouse_position()
    var custom_up:Vector3 = Vector3(0.0, 1.0,0.0)
    #custom up should be 20% towards the camera relative to the up vector. If up is 90 degrees, I want it 70.
    node_quad.look_at(camera.position, custom_up, true)
    pass
    
func rotate_area_to_billboard():
    var camera = get_viewport().get_camera_3d()
    
    # Calculate the direction from the node to the camera
    var direction_to_camera: Vector3 = (camera.global_transform.origin - node_quad.global_transform.origin).normalized()
    
    # Get the camera's up vector
    var camera_up: Vector3 = camera.global_transform.basis.y
    
    # Rotate the node to look at the camera with the camera's up vector
    node_quad.look_at(camera.global_transform.origin, camera_up, true)
    """
    Explanation
    Get the Camera:

    var camera = get_viewport().get_camera_3d(): Get the current 3D camera from the viewport.
    Calculate the Direction to the Camera:

    var direction_to_camera: Vector3 = (camera.global_transform.origin - node_quad.global_transform.origin).normalized(): Calculate the normalized direction vector from the node to the camera.
    Get the Camera's Up Vector:
    ##It's this basis part that confuses me a bit. 
    var camera_up: Vector3 = camera.global_transform.basis.y: Extract the 'up' vector from the camera's transform. This vector represents the camera's 'up' direction.
    Rotate the Node to Look at the Camera:

    node_quad.look_at(camera.global_transform.origin, camera_up): Rotate the node to look at the camera using the camera's 'up' vector. This ensures that the node's 'up' direction is aligned with the camera's 'up' direction.
    """

    
func scale_with_camera_distance():
    #Base parameters: at 200 distance, scale of 1.0.
    #At 1000 distance, scale of 3.0
    var camera = get_viewport().get_camera_3d()
    var distance = camera.position - position
    print("Distance is", distance.length())
    var ratio = inverse_lerp(80, 200, distance.length())
    var sf = lerp(0.9,3.0, ratio)
    sf = clamp(sf, 0.9,2.4)
    scale = Vector3(sf,sf,sf)
