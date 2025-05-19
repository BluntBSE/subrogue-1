@icon("res://engine/abstract_classes/behavior_tree/icons/condition.svg")
extends ConditionLeaf

func tick(actor:Entity, blackboard:BlackBoard):
    var signals:Dictionary = actor.detector.sigmap
    if signals.keys().size() > 0:
        for sig in signals:
            var detected = signals[sig].detected_object
            var profile = signals[sig].detected_object.atts.profile
            if profile > 0.7: #TODO: Make this a variable threshold
                var dist = (detected.global_position - actor.global_position).length()
    else:
        return FAILURE
    #return SUCCESS #Presently unimplemented. Probably need to implement detection first. 
    #Below is quick-and-dirty debug
   # var debug_player = get_tree().root.find_child("PlayerEntity", true, false)
   # if (actor.position - debug_player.position).length() > 2.0:
    return SUCCESS
    #return FAILURE
