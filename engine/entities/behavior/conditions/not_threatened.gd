extends ConditionLeaf


func tick(actor:Entity, blackboard:BlackBoard):
    #return SUCCESS #Presently unimplemented. Probably need to implement detection first. 
    #Below is quick-and-dirty debug
    var debug_player = get_tree().root.find_child("PlayerEntity", true, false)
    if (actor.position - debug_player.position).length() > 2.0:
        print("No player found near the entity")
        return SUCCESS
    print("Player detected near the entity")
    return FAILURE
