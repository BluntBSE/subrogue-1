extends RigidBody3D
class_name Entity
@export var anchor: Node3D
@export var azimuth:float
@export var polar:float
@export var height:float = 105.0; #Given that the planet has a known radius of 100. Height of 5.
@export var move_tolerance = 0.0
@onready var move_bus:EntityMoveBus = get_node("EntityMoveBus")
@export var speed = 20.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    var pos_dict := GlobeHelpers.rads_from_position(position)
    azimuth = pos_dict["azimuth"]
    polar = pos_dict["polar"]
    pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
    handle_input(delta)
    fix_height()
    update_coords()
    move_to_next()
    check_reached_waypoint()

func handle_input(delta: float) -> void:
    if anchor == null:
        return

    #var direction = (global_transform.origin - anchor.global_transform.origin).normalized()
    var force = Vector3.ZERO



    if Input.is_key_label_pressed(KEY_I): # I key
        print("KEY I")
        force += Vector3(1.0,0.0,0.0)
    if Input.is_key_label_pressed(KEY_K): # K key
        force -= Vector3(1.0,0.0,0.0)
    if Input.is_key_label_pressed(KEY_J): # J key
        force -= Vector3(0.0,1.0,0.0)
    if Input.is_key_label_pressed(KEY_L): # L key
        force += Vector3(0.0,1.0,0.0)

    if force != Vector3.ZERO:
        print("Applying impulse at ", force)
        apply_impulse(force) # Adjust the force multiplier as needed

func update_coords()->void:
    var pos_dict := GlobeHelpers.rads_from_position(position)
    azimuth = pos_dict["azimuth"]
    polar = pos_dict["polar"]
    pass

func fix_height()->void:
    #The  entity should always be 5 above the tangential surface of the anchor.
    #If tne anchor has a radius of 100m, the entity shall sit at 105, but not otherwise modify its position.
    #A higher height will be more permissive when colliding with the map
    var direction:Vector3 = (position - anchor.position).normalized()
    var desired_position:Vector3 = anchor.position + (direction * height)
    position = desired_position
    pass

func move_to_next()->void:
    if move_bus.queue.size() < 1:
        return
    if move_bus.queue.size() > 0:
        var dest:Area3D = move_bus.queue[0].waypoint
        move_towards(dest.position)

func move_towards(pos: Vector3) -> void:
    var direction = (pos - position).normalized()
    
    # Calculate the vector from the center of the sphere to the current position
    var center_to_position = (position - anchor.position).normalized()
    
    # Project the direction vector onto the tangent plane
    var tangential_direction = direction - center_to_position * direction.dot(center_to_position)
    tangential_direction = tangential_direction.normalized()
    
    # Calculate the tangential movement vector with the desired speed
    var vector = tangential_direction * speed
    
    # Apply the tangential force
    apply_central_force(vector)
    
func check_reached_waypoint()->void:
    if move_bus.queue.size() < 1:
        return
    var cmd:MoveCommand = move_bus.queue[0]
    var wp:Area3D = cmd.waypoint
    var nav:Area3D = get_node("NavArea")
    var overlaps = nav.get_overlapping_areas()
    if cmd.waypoint in overlaps:
        cmd.is_finished()
    
    
