extends ConditionLeaf

func tick(actor:Entity, blackboard:BlackBoard):
    var fled = blackboard.bbget("recently_fled")
    if fled == null:
        blackboard.bbset("recently_fled", false)
    if fled == false:
        return FAILURE
    else:
        print("Flee existing tick")
        return SUCCESS
