extends ActionLeaf


func tick(actor:Entity, blackboard:BlackBoard):
    print("Happily moving along as", actor.name)
    return RUNNING
