@icon("res://engine/abstract_classes/behavior_tree/icons/condition.svg")
extends ConditionLeaf

func tick(actor:Entity, blackboard:BlackBoard):
    print("Nearby tick")
    var signals:Dictionary = actor.detector.sigmap
    print("Sigmap was ", signals)
    if signals.keys().size() > 0:
        for sig in signals:
            var detected = signals[sig].detected_object
            var profile = signals[sig].detected_object.atts.profile
            if profile > 0.7: #TODO: Make this a variable threshold
                var dist = (detected.global_position - actor.global_position).length()
                print("Dist determined to be ", dist)
                if dist < 12.0:
                    #Right now we don't reason about what's most dangerous, we just flee from the first eligible
                    blackboard.bbset("fleeing_sig", sig) #Signals are hidden, not eliminated during C100, so I think this covers C100 and positive ID
                    return SUCCESS
                    
    else:
        print("No threats nearby")
        return FAILURE
