extends ConditionLeaf



func seek_new_target_passive(actor:Munition):
    var valid_targets: Array = []
    for _entity in actor.detector.local_entities:  #{"entity":entity, "tracked_by":[self, child, child]}
        if _entity == null:
            continue
        #See if the target is within range and can be picked up at all.
        var within = actor.is_within_angle(_entity, 40.0) #TODO: 40 degrees is hardcoded here, oughtn't be
        if within:
            var emission: EntityEmission = _entity.emission
            var sound = Sound.new(_entity, emission.volume, emission.pitch, emission.profile)
            var dist = GlobeHelpers.arc_to_km(actor.global_position, _entity.global_position, actor.anchor)
            var final_db = GlobalConst.attenuate_sound(sound.volume, sound.pitch, dist)
            if final_db > actor.detector.sensitivity:
                valid_targets.append(_entity)

    var closest_target: Entity  #We currently calculate certainty as a function of distance, so "closest" is fine here.
    if valid_targets.size() > 0:
        for target in valid_targets:
            if closest_target == null:
                closest_target = target
            var dist = target.global_position - actor.global_position
            if dist < closest_target.global_position - actor.global_position:
                closest_target = target

    return closest_target
    
func tick(actor:Entity, blackboard:BlackBoard):
    var target = seek_new_target_passive(actor)
    if target == null:
        blackboard.bbset("homing_to", null)
        return FAILURE
    if target == true:
        blackboard.bbset("homing_to", target)
        return SUCCESS
