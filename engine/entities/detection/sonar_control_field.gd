extends Node3D
class_name SonarNode
@export var pulse:bool = false
@onready var own_entity:Entity = get_parent()
var angle_1
var angle_2
var volume
var dist #May be modified based on volume.
var max_dist = 800.0 #In km. This is what the sonar is set to in the UI. It's about 750 KM. We add 50km of buffer to just compensate for any arc shenanigans.
signal pinged

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    pass # Replace with function body.

func _process(delta:float)->void:
    var mesh_1:MeshInstance3D = %SonarPulseMesh
    var entity:Entity = get_parent()
    var up = (entity.anchor.position - entity.position).normalized()
    #This, along wth the funky rotations on the mesh, are how we keep the plane from clipping into the planet.
    mesh_1.look_at(entity.anchor.position)
    mesh_1.rotation.z += deg_to_rad(90.0)

    if pulse == true:

        pulse = false
    pass

func send_pulse():
    #VISUAL ANIMATION
    %SonarPulseMesh.material_override.next_pass.set_shader_parameter("frontier_head", 0.0)
    %SonarPulseMesh.material_override.next_pass.set_shader_parameter("frontier_tail", 0.0)
    var maximum = %SonarPulseMesh.material_override.get_shader_parameter("frontier_head")
    var tween:Tween = get_tree().create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EaseType.EASE_OUT)
    tween.tween_property(%SonarPulseMesh, "material_override:next_pass:shader_parameter/frontier_head", maximum, 1.0).from_current()
    tween.set_trans(Tween.TRANS_CIRC)
    tween.tween_property(%SonarPulseMesh, "material_override:next_pass:shader_parameter/frontier_tail", maximum, 0.5).from_current()
    #WHO DID YOU PING?
    var entities = get_entities_between_angle(%EntityDetector.tracked_entities)
    var range_entities = get_entities_within_range(entities)
    process_entities_with_tween(range_entities, max_dist, 0.5)
    
func process_entities_with_tween(entities: Array, max_distance: float, tween_duration: float):
    # Sort entities by distance
    entities.sort_custom(_compare_entity_distance)

    # Iterate through entities and synchronize with the trans_circ tween
    for entity in entities:
        var timer = Timer.new()
        timer.wait_time = 0.2
        timer.one_shot = true
        timer.connect("timeout", _on_entity_reached.bind(entity))
        add_child(timer)
        timer.start()
        await timer.timeout


# Helper function to compare entities by distance
func _compare_entity_distance(a, b):
    var distance_a = a.global_position.distance_to(own_entity.global_position)
    var distance_b = b.global_position.distance_to(own_entity.global_position)
    return distance_a < distance_b

# Function to handle when the tween catches up with an entity
func _on_entity_reached(entity:Entity):
    print("Entity reached:", entity, "at time ", Time.get_ticks_usec())
    SoundManager.play("button_hover", "randpitch_small", "ui")
    #Move below into something managed by the detector, sent via signal
    for obj in %EntityDetector.sigmap:
        if obj == entity:
            var sig:SignalPopup = %EntityDetector.sigmap[obj]
            if sig.positively_identified == true:
                #Ping contact is also part of positive identification generally, but it's more satisfying to hear it again
                #Even if you already know the ID of what you hit
                pass
                SoundManager.play("ping_contact_1")
            sig.positively_identify()
            
        pass
    
func handle_angle_1(angle):
    print("Handle angle 1 received ", angle)
    #BG
    %SonarPulseMesh.material_override.set_shader_parameter("start_angle", angle)
    #Foreground
    %SonarPulseMesh.material_override.next_pass.set_shader_parameter("start_angle", angle)
    angle_1 = angle

func handle_angle_2(angle):
    %SonarPulseMesh.material_override.set_shader_parameter("end_angle", angle)
    #Foreground
    %SonarPulseMesh.material_override.next_pass.set_shader_parameter("end_angle", angle)
    angle_2 = angle
    pass    

func handle_volume(dict:Dictionary):
    volume = dict.max
    var effective_range = volume * max_dist
    print("Effective ping range", effective_range)
    %SonarPulseMesh.material_override.set_shader_parameter("frontier_head", dict.max)
 
    
    
func handle_ping_request(_angle_1, _angle_2)->void:
    send_pulse()

    
func get_entities_between_angle(entity_list: Array): #Array of dictionaries. You want obj.entity

    # Array to store entities that meet the criteria
    var filtered_entities: Array = []

    # Normalize angle_1 and angle_2. E.g: 370 becomes 10.
    var normalized_angle_1 = normalize_angle(angle_1)
    print("Angle 1 was ", angle_1, "normalized to ", normalized_angle_1)
    
    var normalized_angle_2 = normalize_angle(angle_2)
    print("Angle 2 was ", angle_2, "normalized to", angle_2)

    # Direction from own_entity to the planet's center
    var axis_to_planet: Vector3 = (own_entity.anchor.position - own_entity.position).normalized()

    # Create a vector pointing "above" the entity relative to the sphere's surface
    var global_up: Vector3 = Vector3(0, 1, 0)
    var local_eastwest: Vector3 = global_up.cross(axis_to_planet).normalized()

    # If axis_to_planet is parallel to global_up, use a fallback tangential vector
    if local_eastwest.length() == 0:
        local_eastwest = axis_to_planet.cross(Vector3(1, 0, 0)).normalized()

    var local_northsouth: Vector3 = axis_to_planet.cross(local_eastwest.normalized())
    #visualize_axis(axis_to_planet, own_entity.anchor, Color("ff00ff"))
    #visualize_axis(global_up, own_entity.anchor, Color("ffffff"))
    #visualize_axis(local_eastwest, own_entity.anchor, Color("00ff00"))
    #visualize_axis(local_northsouth, own_entity.anchor, Color("ff0000"))
    for obj in %EntityDetector.tracked_entities: 
        var entity: Entity = obj.entity

        # Calculate the relative position of the entity in global space
        var relative_position = entity.global_position - own_entity.global_position

        # Project the relative position onto the local plane (northsouth/eastwest)
        var entity_position_on_local_plane = Vector3(
            relative_position.dot(local_eastwest),
            relative_position.dot(local_northsouth),
            0  # Ignore the axis_to_planet component for the 2D plane
        )

        # Calculate the angle relative to the northsouth axis (clockwise adjustment)
        var local_angle = rad_to_deg(atan2(
            -entity_position_on_local_plane.x,  # Negate the X component to flip direction
            entity_position_on_local_plane.y   # Y component remains the same
        ))

        # Normalize the angle to [0, 360)
        local_angle = normalize_angle(local_angle)

        # Print the entity's name and its local angle

        # Check if the angle is within the range, handling wrap-around
        if normalized_angle_1 <= normalized_angle_2:
            # Normal case: no wrap-around
            if (normalized_angle_1 <= local_angle) && (local_angle <= normalized_angle_2):
                filtered_entities.append(entity)
        else:
            # Wrap-around case: range spans 0 degrees
            if local_angle >= normalized_angle_1 or local_angle <= normalized_angle_2:
                filtered_entities.append(entity)

    # Print the filtered entities for debugging
    return filtered_entities


func get_entities_within_range(entity_list:Array): #Array of entities
    var filtered_entities = []
    for entity:Entity in entity_list:
        var dist = GlobeHelpers.arc_to_km(own_entity.position, entity.position, own_entity.anchor)
        if dist <= max_dist:
            filtered_entities.append(entity)
    return filtered_entities

func normalize_angle(angle: float) -> float:
    # Normalize the angle to the range [0, 360)
    var normalized = fmod(angle, 360.0)
    if normalized < 0:
        normalized += 360.0
    return normalized
