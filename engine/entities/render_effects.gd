extends Node3D
class_name RenderEffects

var test
var fixed_position_effects = []


#COUNTERPING
#This fires when a player entity is successfully pinged by another entity in the world
func _unhandled_key_input(event: InputEvent) -> void:
    if %SonarNode.own_entity.played_by != null:
        if event is InputEventKey and event.is_released() and event.keycode == KEY_Q:
            print("Should be firing an example counterping")
            counterping_example()


func counterping_example():
    var axis = (%SonarNode.own_entity.global_position - %SonarNode.own_entity.anchor.global_position).normalized()
    var point = determine_random_origin(global_position, axis)
    print("effect global position was ", global_position)
    send_counterping_from(point+global_position, global_position, axis)

func generate_ping_mesh():
    var mesh:GenericPing = preload("res://engine/player_ui/3d_ui/active_sonar/generic_ping.tscn").instantiate()
    #TODO: Any unpack/color setting, etc.
    return mesh

func send_counterping_from(pos:Vector3, to:Vector3, axis:Vector3, width:float = 40.0):
    var mesh:GenericPing = generate_ping_mesh()
    add_child(mesh)
    mesh.global_position = pos
    mesh.look_at(axis)
    mesh.top_level = true
    mesh.track_target = self
    #mesh.follow_target = self
   # mesh.initial_offset = (pos - global_position)
    mesh.ping(pos, to, axis)
    mesh.finished.connect(func():mesh.queue_free())
    #await finished then cleanup


func determine_random_origin(pos:Vector3, axis:Vector3): #TODO: Add the randomness later
    var local_basis = GlobeHelpers.get_aligned_basis(axis)
    var point = create_point_with_local_space(position, axis, 10.0, 20.0) #1 game unit away, 20.0 degrees northeast
    return point
    

func create_point_with_local_space(origin: Vector3, axis: Vector3, distance: float, local_angle_deg: float) -> Vector3:
    # Get the local coordinate system
    var local_basis: Dictionary = GlobeHelpers.get_aligned_basis(axis)
    var local_northsouth = local_basis.up
    var local_eastwest = local_basis.right

    # Convert angle to radians
    var local_angle_rad = deg_to_rad(local_angle_deg)

    # Calculate the local position based on angle and distance
    # This creates a point on the local xy plane (formed by northsouth and eastwest)
    var local_x = distance * sin(local_angle_rad)  # Component along local_eastwest
    var local_y = distance * cos(local_angle_rad)  # Component along local_northsouth

    # Transform local coordinates to global coordinates
    # This is done by scaling the local basis vectors and adding to origin
    var out_position = origin
    out_position += local_eastwest * local_x
    out_position += local_northsouth * local_y
    print("Local position was ", out_position)

    return out_position
