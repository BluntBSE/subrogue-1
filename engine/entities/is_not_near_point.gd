extends ConditionLeaf

func tick(actor: Entity, blackboard: BlackBoard):
    var current_command: MoveCommand
    var current_waypoint
    var tolerance
    
    if actor.move_bus.queue.size() > 0:
        current_command = actor.move_bus.queue[0]
        current_waypoint = current_command.waypoint
        tolerance = current_command.tolerance
    else:
        return FAILURE

    
    # Retrieve the previous command from the blackboard
    var previous_command = blackboard.bbget("previous_command")
    
    # If the current command has changed, update the blackboard and return FAILURE
    if previous_command != current_command:
        blackboard.bbset("previous_command", current_command)
        print("Entity reached the target waypoint:", current_waypoint)
        return FAILURE
        
    #If there are any reasons to NOT path, return failure. E.G: enemy detection
    
    # If there is not an active waypoint in the behavior tree...
    if blackboard.bbget("active_waypoint") == null:
        blackboard.bbset("active_waypoint", current_waypoint)
    
    # Check if the current waypoint is the same as the active waypoint
    if current_waypoint == blackboard.bbget("active_waypoint"):
        # Meaning that we HAVE NOT REACHED the destination
        return SUCCESS
    
    # If the current waypoint has changed, update the active waypoint and return FAILURE
    blackboard.bbset("active_waypoint", current_waypoint)
    return FAILURE
