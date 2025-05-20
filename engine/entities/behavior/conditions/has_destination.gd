extends ConditionLeaf


func tick(actor:Entity, blackboard:BlackBoard):
    if actor.move_bus.queue.size() > 0:
        return SUCCESS #Does NOT have destination.
    
    else:
        return FAILURE
