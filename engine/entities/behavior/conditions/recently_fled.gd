extends ConditionLeaf

func tick(actor:Entity, blackboard:BlackBoard):
    print("Hello from flee check")
    var fled = blackboard.bbget("recently_fled")
    if fled == null:
        blackboard.bbset("recently_fled", false)
    if fled == false:
        print("WAT")
        return FAILURE
    else:
        print("YES")
        return SUCCESS
