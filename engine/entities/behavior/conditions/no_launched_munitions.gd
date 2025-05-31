extends ConditionLeaf

func tick(actor:Entity, blackboard:BlackBoard):
    if blackboard.bbget("current_launched_munition") == null:
        return SUCCESS
    else:
        return FAILURE
