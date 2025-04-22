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
    
func get_entities_between_angle_bad(entity_list: Array):

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
    var local_northsouth: Vector3 = global_up.cross(axis_to_planet).normalized()

    # If axis_to_planet is parallel to global_up, use a fallback tangential vector
    if local_northsouth.length() == 0:
        local_northsouth = axis_to_planet.cross(Vector3(1, 0, 0)).normalized()

    var local_eastwest: Vector3 = axis_to_planet.cross(local_northsouth).normalized()
    visualize_axis(axis_to_planet, own_entity.anchor, Color("ff00ff"))
    visualize_axis(global_up, own_entity.anchor, Color("ffffff"))
    visualize_axis(local_eastwest, own_entity.anchor, Color("00ff00"))
    visualize_axis(local_northsouth, own_entity.anchor, Color("ff0000"))

func normalize_angle(angle: float) -> float:
    # Normalize the angle to the range [0, 360)
    var normalized = fmod(angle, 360.0)
    if normalized < 0:
        normalized += 360.0
    return normalized


func visualize_axis(axis, anchor, color):
    var debug_draw := ImmediateMesh.new()
    debug_draw.surface_begin(Mesh.PRIMITIVE_TRIANGLES)

    # Define the box's dimensions
    var length = 60.0  # Total length along to_planet
    var width = 1.0    # Width of the box
    var height = 1.0   # Height of the box

    # Calculate the rectangle's base vertices
    var forward = axis.normalized() * (length / 2.0)  # Half-length forward and backward
    var right = Vector3(0, 1, 0).cross(forward).normalized() * (width / 2.0)  # Perpendicular vector for width
    var up = Vector3(0, 1, 0).normalized() * (height / 2.0)  # Vertical height

    # Top face vertices
    var top_front_left = forward + right + up
    var top_front_right = forward - right + up
    var top_back_left = -forward + right + up
    var top_back_right = -forward - right + up

    # Bottom face vertices
    var bottom_front_left = forward + right - up
    var bottom_front_right = forward - right - up
    var bottom_back_left = -forward + right - up
    var bottom_back_right = -forward - right - up

    # Add vertices for the top face (two triangles)
    debug_draw.surface_add_vertex(top_front_left)
    debug_draw.surface_add_vertex(top_back_left)
    debug_draw.surface_add_vertex(top_front_right)

    debug_draw.surface_add_vertex(top_back_left)
    debug_draw.surface_add_vertex(top_back_right)
    debug_draw.surface_add_vertex(top_front_right)

    # Add vertices for the bottom face (two triangles)
    debug_draw.surface_add_vertex(bottom_front_left)
    debug_draw.surface_add_vertex(bottom_front_right)
    debug_draw.surface_add_vertex(bottom_back_left)

    debug_draw.surface_add_vertex(bottom_back_left)
    debug_draw.surface_add_vertex(bottom_front_right)
    debug_draw.surface_add_vertex(bottom_back_right)

    # Add vertices for the side faces (four sides, two triangles each)
    # Front face
    debug_draw.surface_add_vertex(top_front_left)
    debug_draw.surface_add_vertex(bottom_front_left)
    debug_draw.surface_add_vertex(top_front_right)

    debug_draw.surface_add_vertex(bottom_front_left)
    debug_draw.surface_add_vertex(bottom_front_right)
    debug_draw.surface_add_vertex(top_front_right)

    # Back face
    debug_draw.surface_add_vertex(top_back_left)
    debug_draw.surface_add_vertex(top_back_right)
    debug_draw.surface_add_vertex(bottom_back_left)

    debug_draw.surface_add_vertex(bottom_back_left)
    debug_draw.surface_add_vertex(top_back_right)
    debug_draw.surface_add_vertex(bottom_back_right)

    # Left face
    debug_draw.surface_add_vertex(top_front_left)
    debug_draw.surface_add_vertex(top_back_left)
    debug_draw.surface_add_vertex(bottom_front_left)

    debug_draw.surface_add_vertex(bottom_front_left)
    debug_draw.surface_add_vertex(top_back_left)
    debug_draw.surface_add_vertex(bottom_back_left)

    # Right face
    debug_draw.surface_add_vertex(top_front_right)
    debug_draw.surface_add_vertex(bottom_front_right)
    debug_draw.surface_add_vertex(top_back_right)

    debug_draw.surface_add_vertex(bottom_front_right)
    debug_draw.surface_add_vertex(bottom_back_right)
    debug_draw.surface_add_vertex(top_back_right)

    # End drawing
    debug_draw.surface_end()

    # Create a MeshInstance3D and assign the mesh
    var mesh := MeshInstance3D.new()
    mesh.mesh = debug_draw

    # Create a double-sided material
    var material = StandardMaterial3D.new()
    material.cull_mode = BaseMaterial3D.CULL_DISABLED  # Disable back-face culling
    material.albedo_color = color
    # Assign the material to the mesh
    mesh.material_override = material

    # Add the mesh to the anchor node
    anchor.add_child(mesh)
    mesh.global_position = global_position
