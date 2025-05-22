@icon("res://engine/abstract_classes/behavior_tree/icons/condition.svg")
extends ConditionLeaf

func tick(actor:Entity, blackboard:BlackBoard):
    var signals:Dictionary = actor.detector.sigmap
    if signals.keys().size() > 0:
        for sig in signals:
            if sig == null:
                continue
            var detected = signals[sig].detected_object
            var profile = signals[sig].detected_object.atts.profile
            if profile > 0.7: #TODO: Make this a variable threshold
                var dist = (detected.global_position - actor.global_position).length()
                if dist < 12.0: #TODO: Probably need to make a variable
                    #Right now we don't reason about what's most dangerous, we just flee from the first eligible
                    blackboard.bbset("fleeing_sig", sig) #Signals are hidden, not eliminated during C100, so I think this covers C100 and positive ID
                    print("THREAT DETECTED")
                    return SUCCESS
                    
    else:
        return FAILURE
