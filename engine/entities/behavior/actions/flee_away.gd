extends ActionLeaf

func tick(actor:Entity, blackboard:BlackBoard):
    print("Hello from flee away")
    var fleeing_sig = blackboard.bbget("fleeing_sig")
    var away_direction = (fleeing_sig.global_position - actor.global_position).normalized() * -1.0
    var away = away_direction * 3.0 #TODO: Maybe need to check if this would take us onto land. It might also be nice to 'beach' people
    print("Generating move command for ", actor.atts.display_name)
    var dest = GlobeHelpers.generate_move_command(actor, away)
    actor.controller.relay_order_move(dest)
    blackboard.bbset("recently_fled", true)
    blackboard.bbset("last_fled_time", Time.get_ticks_msec())
    return SUCCESS
