extends ActionLeaf


func tick(actor:Entity, blackboard:BlackBoard):
    print("Keep moving from  ", actor.name)
    return RUNNING
