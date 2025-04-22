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
    get_entities_between_angle_bad(%EntityDetector.tracked_entities)
    #get_entities_between_angle_good(%EntityDetector.tracked_entities)
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
    
func get_entities_between_angle_bad(entity_list: Array) -> Array:

    # Array to store entities that meet the criteria
    var filtered_entities: Array = []

    # Normalize angle_1 and angle_2. E.g: 370 becomes 10.
    var normalized_angle_1 = normalize_angle(angle_1)
    var normalized_angle_2 = normalize_angle(angle_2)

    # Direction from own_entity to the planet's center
    var axis_to_planet: Vector3 = (own_entity.anchor.position - own_entity.position).normalized()

    # Create a vector pointing "above" the entity relative to the sphere's surface
    var global_up: Vector3 = Vector3(0, 1, 0)
    var local_northsouth: Vector3 = global_up.cross(axis_to_planet).normalized()

    # If axis_to_planet is parallel to global_up, use a fallback tangential vector
    if local_northsouth.length() == 0:
        local_northsouth = axis_to_planet.cross(Vector3(1, 0, 0)).normalized()

    var local_eastwest: Vector3 = axis_to_planet.cross(local_northsouth).normalized()
    visualize_wedge(local_northsouth, local_eastwest, angle_1, angle_2)
    for obj in entity_list:
        var entity: Entity = obj.entity

        # Direction from own_entity to the detected entity
        var direction_to_entity: Vector3 = (entity.position - own_entity.position).normalized()
        #Get the entity's position on the local plane of local_northsouth, local_eastwest
        var entity_position_on_local_plane = Vector3(
            direction_to_entity.dot(local_northsouth),
            direction_to_entity.dot(local_eastwest),
            0  # The Z-component is 0 because it's on the local plane
        )     
        
        #Get the entity's angle relative to own_entity on this plane. Being directly ahead on local_northsouth should be an angle of 0. 
        var local_angle = rad_to_deg(atan2(entity_position_on_local_plane.y, entity_position_on_local_plane.x))
        print("local angle of  ", entity.given_name, " is ", local_angle)
    # Print the filtered entities for debugging
    print("Filtered entities from bad function:", filtered_entities)

    return filtered_entities

func normalize_angle(angle: float) -> float:
    # Normalize the angle to the range [0, 360)
    var normalized = fmod(angle, 360.0)
    if normalized < 0:
        normalized += 360.0
    return normalized



func visualize_wedge(ns, ew, angle_1, angle_2):
    var  node:Node3D = %DebugMeshes
    for child in node.get_children():
        child.queue_free()
    # Create or get an ImmediateGeometry node for visualization
    var debug_mesh:MeshInstance3D = MeshInstance3D.new()
    var debug_draw = ImmediateMesh.new()
 

    # Clear previous drawings
    debug_draw.clear_surfaces()

    # Start drawing
    debug_draw.surface_begin(Mesh.PRIMITIVE_TRIANGLES)

    # Add the center point of the wedge
    debug_draw.surface_add_vertex(Vector3.ZERO)

    # Calculate the wedge points

    var first_angle = deg_to_rad(angle_1)
    var first_point = ns * cos(first_angle) + ew * sin(first_angle)
    debug_draw.surface_add_vertex(first_point * 30.0)  # Scale the wedge outward
    
    var second_angle = deg_to_rad(angle_2)
    var second_point = ns * cos(second_angle) + ew * sin(second_angle)
    debug_draw.surface_add_vertex(second_point * 30.0)
    # End drawing
    debug_draw.surface_end()
    debug_mesh.mesh = debug_draw
    debug_mesh.name = "debug_mesh"
    %DebugMeshes.add_child(debug_mesh)
    debug_mesh.rotation.y += deg_to_rad(90.0)
    debug_mesh.rotation.z += deg_to_rad(180.0)
