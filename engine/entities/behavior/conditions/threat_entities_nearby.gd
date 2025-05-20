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
                if dist < 12.0:
                    #Right now we don't reason about what's most dangerous, we just flee from the first eligible
                    blackboard.bbset("fleeing_sig", sig)
                    return SUCCESS
                    
    else:
        return FAILURE
