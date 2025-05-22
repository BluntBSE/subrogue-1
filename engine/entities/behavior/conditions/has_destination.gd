extends ConditionLeaf


func tick(actor:Entity, blackboard:BlackBoard):
    print("Hello from has dest")
    if actor.behavior.destination_node:
        return SUCCESS
    else:
        return FAILURE
