class_name GlobeHelpers


static func visualize_axis(target, axis, anchor, color):
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
    print("Visualize axis attempted to add ", mesh, " to ", anchor.name)
    mesh.global_position = target.global_position
    
static func get_aligned_basis(axis:Vector3) -> Dictionary:
    var forward = axis.normalized() #Facing away from the planet/anchor
    var right = Vector3(0, 1, 0).cross(forward).normalized()
    
    # Handle case where axis might be aligned with global up
    if right.length_squared() < 0.001:
        right = Vector3(1, 0, 0)
    
    var up = forward.cross(right).normalized()
    
    return {
        "forward": forward, #Usually "away from sphere". Local updown
        "right": right, #Usually local eastwest
        "up": up #USually local northsouth 
    }

static func normalize_angle(angle: float) -> float:
    # Normalize the angle to the range [0, 360)
    var normalized = fmod(angle, 360.0)
    if normalized < 0:
        normalized += 360.0
    return normalized
    
static func get_local_angle_between(to:Vector3, from:Vector3, axis:Vector3):
    var relative_position = to - from #Expecting global positions, basically
    var local_basis:Dictionary = get_aligned_basis(axis) #Usually dir to planet
    #Generally speaking, entities use look_at() to keep facing the planet. This puts their forward axis in the updown direction.
    #The user will perceive northsouth as 'up'.
    var local_northsouth = local_basis.up
    var local_eastwest = local_basis["right"]
    var local_updown = local_basis["forward"]
    
    #var angle = to_entity.angle_to(local_northsouth) - We need a signed angle, so a simple angle_to won't suffice.
    #signed angles come from angle = atan2(determinant, dotproduct)
    var entity_position_on_local_plane = Vector3(
        relative_position.dot(local_eastwest),
        relative_position.dot(local_northsouth),
        0  # Ignore the axis_to_planet component for the 2D plane
    )

    # Calculate the angle relative to the northsouth axis (clockwise adjustment)
    var local_angle = rad_to_deg(atan2(
        entity_position_on_local_plane.x,  
        entity_position_on_local_plane.y 
    ))
    
    local_angle = normalize_angle(local_angle)
    
    return local_angle


func visualize_entity_position(entity_position, anchor, color):
    # Create a sphere mesh
    var sphere_mesh := SphereMesh.new()
    sphere_mesh.radius = 1.0  # Set the radius of the sphere
    sphere_mesh.height = 1.0  # Set the height of the sphere

    # Create a MeshInstance3D to hold the sphere
    var sphere_instance := MeshInstance3D.new()
    sphere_instance.mesh = sphere_mesh

    # Create an orange material
    var material := StandardMaterial3D.new()
    material.albedo_color = color  # Orange color
    sphere_instance.material_override = material

    # Set the sphere's position in the local 2D plane
    sphere_instance.global_position = entity_position

    # Add the sphere to the anchor node
    anchor.add_child(sphere_instance)


static func rads_from_position(vec:Vector3)->Dictionary:
    var db := true
    #The centerpoint of the globe is vec3(0.0), so:
    var distance = vec.distance_to(Vector3(0.0,0.0,0.0))
    var polar = asin(vec.y/distance)
    var azimuth = atan2(vec.z, vec.x) #Check this later. I don't know if I trust it yet.
    var dict =  {
        "azimuth":azimuth,
        "polar":polar
    }
    var dstr = "rads from position returned" + str(dict)
    dh.dprint(false, null, dstr)
    return dict
    
static func fix_height(entity:Node3D, anchor:Node3D)->Vector3:
    #The  entity should always be 5 above the tangential surface of the anchor.
    #If tne anchor has a radius of 100m, the entity shall sit at 105, but not otherwise modify its position.
    #A higher height will be more permissive when colliding with the map
    var direction:Vector3 = (entity.position - anchor.position).normalized()
    var desired_position:Vector3 = anchor.position + (direction * GlobalConst.height)
    return desired_position
    
    
    
static func arc_to_km(point_a:Vector3, point_b:Vector3, anchor:Planet) -> float:
    var anchor_mesh:SphereMesh = anchor.mesh
    var sphere_radius = anchor_mesh.radius # This is 100 right now in game units
    var earth_radius_km = 6378
    var earth_height_km = 6378 # This technically isn't true but whatever

    # Calculate the normalized positions of point_a and point_b on the sphere
    var normalized_a = (point_a - anchor.global_transform.origin).normalized()
    var normalized_b = (point_b - anchor.global_transform.origin).normalized()

    # Calculate the angle between the two points in radians
    var dot_product = normalized_a.dot(normalized_b)
    var angle_radians = acos(dot_product)

    # Calculate the arc distance in game units
    var arc_distance_game_units = angle_radians * sphere_radius

    # Convert the arc distance from game units to kilometers
    var arc_distance_km = (arc_distance_game_units / sphere_radius) * earth_radius_km

    return arc_distance_km
    
static func km_to_arc_distance(km: float, anchor: Planet) -> float:
    var anchor_mesh: SphereMesh = anchor.mesh
    var sphere_radius = anchor_mesh.radius # This is 100 right now in game units
    var earth_radius_km = 6378

    # Convert the distance from kilometers to game units
    var arc_distance_game_units = (km / earth_radius_km) * sphere_radius

    return arc_distance_game_units

static func kph_to_game_s(kph: float) -> float:
    var sphere_radius = 100.0 # in game units
    var earth_radius_km = 6378.0 # in kilometers
    
    # Calculate the conversion factor from kilometers to game units
    var conversion_factor = sphere_radius / earth_radius_km
    
    # Convert kph to kilometers per MINUTE.
    # We conver to kilometers per MINUTE because the root timescale of the game is 1 game second = 1 real world minute.
    var kpmin = kph / 60
    
    # Convert kilometers per second to game units per second
    var game_units_per_second = kpmin * conversion_factor
    
    return game_units_per_second
    


static func game_s_to_kph(game_units_per_second: float) -> float:
    var sphere_radius = 100.0 # in game units
    var earth_radius_km = 6378.0 # in kilometers
    
    # Calculate the conversion factor from game units to kilometers
    var conversion_factor = earth_radius_km / sphere_radius
    
    # Convert game units per second to kilometers per minute
    var kpmin = game_units_per_second * conversion_factor
    
    # Convert kilometers per minute to kilometers per hour
    var kph = kpmin * 60
    
    return kph

static func generate_move_command(entity:Entity, target_position:Vector3, layer:int = 2, mask:int = 2) ->MoveCommand:
    print("Generate move command ifred for ", entity.atts.display_name)
    var waypoint:Area3D = Area3D.new()
    var wp_collider := CollisionShape3D.new()
    var wp_shape := SphereShape3D.new() #default radius of 0.5. If we use tolerance, this might be what we assign it to.
    #Consider making these waypoints a child of the player's abstract node.
    wp_collider.shape = wp_shape
    waypoint.collision_layer = 2
    waypoint.collision_mask = 2
    waypoint.name = "NAV_WAYPOINT_FOR_" + str(entity.name)
    waypoint.add_child(wp_collider)
    entity.anchor.add_child(waypoint)

    waypoint.position = target_position
    waypoint.position = GlobeHelpers.fix_height(waypoint, entity.anchor)
    
    var move_command := MoveCommand.new()
    move_command.entity = entity
    var bus:EntityMoveBus = entity.move_bus
    var target_azimuth = GlobeHelpers.rads_from_position(target_position).azimuth
    var target_polar = GlobeHelpers.rads_from_position(target_position).polar
    
    if entity.azimuth == null:
        entity.azimuth = GlobeHelpers.rads_from_position(entity.position).azimuth
    if entity.polar == null:
        entity.polar = GlobeHelpers.rads_from_position(entity.position).polar
    #TODO: When to set speed?
    if entity.speed == null:
        entity.speed = entity.max_speed
        
    move_command.start_azimuth = entity.azimuth
    move_command.start_polar = entity.polar
    move_command.end_azimuth = target_azimuth
    move_command.end_polar = target_polar
    move_command.tolerance = entity.move_tolerance #Usually 0.0, intolerant.
    move_command.waypoint = waypoint
    
    return move_command
    
static func offset_position_by_km(point: Vector3, direction: Vector3, km: float, anchor: Planet) -> Vector3:
    var anchor_mesh: SphereMesh = anchor.mesh
    var sphere_radius = anchor_mesh.radius # This is 100 right now in game units

    # Convert the distance from kilometers to arc distance in game units
    var arc_distance_game_units = km_to_arc_distance(km, anchor)
    
    var new_position = arc_distance_game_units * direction
    
    
    return new_position

static func recursively_update_visibility(node, layer, _visible):
    for child in node.get_children():
        if child.get("layers") != null:
            child.set_layer_mask_value(layer, _visible)
        recursively_update_visibility(child,layer, _visible)
