extends Node3D
class_name SonarNode
@export var pulse:bool = false
@onready var own_entity:Entity = get_parent()
var angle_1
var angle_2


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
    #Maybe need to store those angle 1, 2, and volume here as well as on shader
    get_entities_between_angle(%EntityDetector.tracked_entities)
    
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
    %SonarPulseMesh.material_override.set_shader_parameter("frontier_head", dict.max)

func handle_ping_request(_angle_1, _angle_2)->void:
    send_pulse()

func get_entities_between_angle(entity_list: Array) -> Array:
    # Array to store entities that meet the criteria
    var filtered_entities: Array = []

    # Normalize angle_1 and angle_2
    var normalized_angle_1 = normalize_angle(angle_1)
    var normalized_angle_2 = normalize_angle(angle_2)

    # Direction from own_entity to the planet's center
    var axis_to_planet: Vector3 = (own_entity.anchor.position - own_entity.position).normalized()

    # Create a vector pointing "above" the entity relative to the sphere's surface
    var global_up: Vector3 = Vector3(0, 1, 0)
    var tangential_vector: Vector3 = global_up.cross(axis_to_planet).normalized()

    # If axis_to_planet is parallel to global_up, use a fallback tangential vector
    if tangential_vector.length() == 0:
        tangential_vector = axis_to_planet.cross(Vector3(1, 0, 0)).normalized()

    # Rotate the tangential vector to align with the "upward" direction relative to the sphere
    var upward_vector: Vector3 = axis_to_planet.cross(tangential_vector).normalized()

    for obj in entity_list:
        var entity: Entity = obj.entity

        # Direction from own_entity to the detected entity
        var direction_to_entity: Vector3 = (entity.position - own_entity.position).normalized()

        # Calculate the angle between upward_vector and direction_to_entity
        var angle_to_entity: float = rad_to_deg(upward_vector.angle_to(direction_to_entity))
        angle_to_entity = normalize_angle(angle_to_entity)

        print("Angle to entity ", entity.given_name, "was ", angle_to_entity)
        print("Normalized Angle 1: ", normalized_angle_1, "Normalized Angle 2: ", normalized_angle_2)

        # Check if the angle is within the specified range
        if normalized_angle_1 <= normalized_angle_2:
            # Normal case: no wrap-around
            if (normalized_angle_1 <= angle_to_entity) && (angle_to_entity <= normalized_angle_2):
                # Calculate the distance to the entity
                var distance: float = own_entity.position.distance_to(entity.position)
                print("Distance to entity ", entity.given_name, "was ", distance)

                # Check if the entity is within the specified distance
                if distance <= 30.0:
                    filtered_entities.append(entity)
        else:
            # Wrap-around case: range spans 0 degrees
            if (angle_to_entity >= normalized_angle_1) || (angle_to_entity <= normalized_angle_2):
                # Calculate the distance to the entity
                var distance: float = own_entity.position.distance_to(entity.position)
                print("Distance to entity ", entity.given_name, "was ", distance)

                # Check if the entity is within the specified distance
                if distance <= 30.0:
                    filtered_entities.append(entity.given_name)

    # Print the filtered entities for debugging
    print("Filtered entities:", filtered_entities)

    return filtered_entities


func normalize_angle(angle: float) -> float:
    # Normalize the angle to the range [0, 360)
    var normalized = fmod(angle, 360.0)
    if normalized < 0:
        normalized += 360.0
    return normalized
