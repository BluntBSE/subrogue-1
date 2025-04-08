class_name MunitionHelpers

static func munition_by_id(id: String) -> Munition:
    var new_munition: Munition = preload("res://engine/entities/munitions/munition_entity.tscn").instantiate()
    var munitions_data = GlobalConst.munitions_lib
    print("Loading by string, id", id)
    var munition_data = munitions_data.get(id)
    
    new_munition.id = munition_data.id
    new_munition.display_name = munition_data.display_name
    new_munition.guidance_type = munition_data.guidance_type
    new_munition.impact_radius = munition_data.impact_radius
    new_munition.fuel_remaining = munition_data.fuel_remaining
    new_munition.fuel_max = munition_data.fuel_max
    new_munition.fuel_burn = munition_data.fuel_burn
    #new_munition.current_depth = munition_data.current_depth
    new_munition.target_depths = munition_data.target_depths
    new_munition.target_pos = munition_data.target_pos
    new_munition.sprite_override = munition_data.sprite_override
    new_munition.max_speed = GlobeHelpers.kph_to_game_s(munition_data.max_speed)
    new_munition.impact_type = munition_data.impact_type
    #NOT FROM DATA / Should come from launch configuration
    new_munition.speed = new_munition.max_speed
    new_munition.fuel_remaining = new_munition.fuel_max
    new_munition.current_depth = munition_data.current_depth
    
    print("NEW MUNITION IS, ", new_munition)
    
    return new_munition
