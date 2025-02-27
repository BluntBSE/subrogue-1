class_name GlobeHelpers


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

static func generate_move_command(entity:Entity, target_position:Vector3, layer:int = 2, mask:int = 2) ->MoveCommand:
    print("MOVE COMMAND GENERATED FOR ENTITY: ", entity.name)
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
    print("Original position", point)
    var anchor_mesh: SphereMesh = anchor.mesh
    var sphere_radius = anchor_mesh.radius # This is 100 right now in game units

    # Convert the distance from kilometers to arc distance in game units
    var arc_distance_game_units = km_to_arc_distance(km, anchor)
    
    var new_position = arc_distance_game_units * direction
    print("New position ", new_position)
    
    
    return new_position
