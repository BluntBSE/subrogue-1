extends ConditionLeaf


func tick(actor:Entity, blackboard:BlackBoard):
    if actor.move_bus.queue.size() > 0:
        return SUCCESS
    
    else:
        if actor.behavior.destination_node:# or actor.behavior.destination_position:
            var path = actor.move_bus.path_between_nodes(actor.move_bus.find_closest_node(), actor.behavior.destination_node, get_tree().root.find_child("NavNodes", true, false))
            actor.move_bus.waypoints_from_nodes(path)
            if actor.move_bus.queue.size() > 0:
                return SUCCESS
    return FAILURE
