extends ConditionLeaf


func tick(actor:Entity, blackboard:BlackBoard):
    if actor.move_bus.queue.size() < 1:
        return FAILURE
    var node_dist = actor.behavior.destination_node.global_position - actor.move_bus.queue[-1].waypoint.global_position
    #Nav Nodes are snapped to the surface of the sphere, but they could be slightly off, so...
    if node_dist.length() < 0.2: #This is about right. 0.
        return SUCCESS
    else:
        return FAILURE
