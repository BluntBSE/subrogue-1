extends ActionLeaf

func tick(actor:Entity, blackboard:BlackBoard):
    var target_entity = blackboard.bbget("homing_to")
    var move_command = GlobeHelpers.generate_move_command(actor, target_entity.global_position)
    actor.controller.order_move.emit(move_command)
