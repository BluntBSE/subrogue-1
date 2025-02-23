extends Decorator

class_name Limiter

@onready var cache_key = 'limiter_%s' % get_instance_id()

@export var max_count:int = 0

func tick(actor, blackboard:BlackBoard):
    var current_count = blackboard.bbget(cache_key)

    if current_count == null:
        current_count = 0

    if current_count <= max_count:
        blackboard.bbset(cache_key, current_count + 1)
        return self.get_child(0).tick(actor, blackboard)
    else:
        return FAILED
