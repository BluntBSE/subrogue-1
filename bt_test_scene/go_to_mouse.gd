extends ActionLeaf


func tick(actor:Sprite2D, blackboard:BlackBoard):
    var mouse_position = get_viewport().get_mouse_position()
    var speed:float = 2.0
    var dir:Vector2 = (mouse_position-actor.position).normalized()
    actor.position += dir * speed
    if actor.position.distance_to(mouse_position) < 1:
        return SUCCESS
    return RUNNING
