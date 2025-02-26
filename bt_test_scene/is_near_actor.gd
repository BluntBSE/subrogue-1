extends ConditionLeaf


func tick(actor:Sprite2D, blackboard:BlackBoard):
    var mouse_position = get_viewport().get_mouse_position()

    #print("Tick called on actionleaf, agent is", actor)
    if actor.position.distance_to(mouse_position) < 300:
        return SUCCESS
        
    return FAILURE
