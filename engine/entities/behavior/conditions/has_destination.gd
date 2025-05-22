extends ConditionLeaf


func tick(actor:Entity, blackboard:BlackBoard):
    if actor.behavior.destination_node:
        return SUCCESS
    else:
        return FAILURE
