extends ActionLeaf

var local_blackboard:BlackBoard

func tick(actor:Entity, blackboard:BlackBoard):
    if not local_blackboard:
        local_blackboard = blackboard
    var threat_sig = blackboard.bbget("threat_sig")
    var dest = GlobeHelpers.generate_move_command(actor, threat_sig.global_position)
    var args = {"munition": actor.munitions.active_munition, "start_position": actor.global_position, "target_position": threat_sig.global_position, "originating_entity": actor}
    var munition = actor.munitions.launch_munition(args)
    munition.died.connect(handle_entity_died)
    blackboard.bbset("current_launched_munition", munition )
    return SUCCESS


func handle_entity_died(entity:Entity):
    local_blackboard.bbset("current_launched_munition", null)
    pass
