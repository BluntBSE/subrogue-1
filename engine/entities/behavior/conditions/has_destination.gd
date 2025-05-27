extends ConditionLeaf


func tick(actor:Entity, blackboard:BlackBoard):
    print("Hello from has destination for", actor.name)
    if actor.behavior.destination_node:
        print("Yes destination")
        return SUCCESS
    else:
        print("No destination")
        return FAILURE
