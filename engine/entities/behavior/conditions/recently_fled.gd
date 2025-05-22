extends ConditionLeaf

func tick(actor:Entity, blackboard:BlackBoard):
    var fled = blackboard.bbget("recently_fled")
    if fled == null:
        blackboard.bbset("recently_fled", false)
    if fled == false:
        return SUCCESS #As in, "this is the leaf we want to stay on."
    else:
        print("Flee existing tick")
        return FAILURE #Move on from this leaf down the tree.
