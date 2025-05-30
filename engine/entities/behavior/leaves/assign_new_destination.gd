extends ActionLeaf

func tick(actor:Entity, blackboard:BlackBoard):
    actor.move_bus.order_destination_path()
    if actor.move_bus.queue.size() > 0:
        return SUCCESS
    else:
        actor.crash_me() #This code should theoretically be unreachable since any entity at its destination node
        #Should dock. However, this might change if we implement parking at locations. We'll see!
        return FAILURE
