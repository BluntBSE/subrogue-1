extends ConditionLeaf


func tick(actor:Entity, blackboard:BlackBoard):
    if actor.behavior.destination_node or actor.behavior.destination_position:
        print("Checking for has destination")
        return SUCCESS
    
    print("Behaviortree failure in ", actor.name, "no destination found. This may or may not be an error")
    return FAILURE
