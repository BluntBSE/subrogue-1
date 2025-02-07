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
    dh.dprint(true, dstr)
    return dict
    
static func fix_height(entity:Node3D, anchor:Node3D)->Vector3:
    #The  entity should always be 5 above the tangential surface of the anchor.
    #If tne anchor has a radius of 100m, the entity shall sit at 105, but not otherwise modify its position.
    #A higher height will be more permissive when colliding with the map
    var direction:Vector3 = (entity.position - anchor.position).normalized()
    var desired_position:Vector3 = anchor.position + (direction * GlobalConst.height)
    return desired_position
