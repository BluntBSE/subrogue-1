extends EventBus
class_name EntityMoveBus

var max_size = 5 #Number of waypoints that can be queued up.
var waypoints := []

func _ready()->void:
    var entities:PlayerEntities = %PlayerEntities
    entities.order_move.connect(handle_order_move)
    entities.enqueue_move.connect(handle_enqueue_move)
    


func handle_order_move(command:MoveCommand)->void:
    add(command)
    command.finished.connect(handle_finished)
    purge_old_waypoints()


    
func handle_enqueue_move(command:MoveCommand)->void:
    add(command)
    

func add(command:Command)->void:
    queue.push_front(command)
    pass


func handle_finished(command:MoveCommand):
    command.waypoint.queue_free()
    queue.erase(command)
    command.queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass
    
    
func purge_old_waypoints():
    # For allowing the active move command to be continually updated with mouse position
    # Erase for every member of the queue that is not at queue[0]
    while queue.size() > 1:
        var command: MoveCommand = queue[1]
        var callable: Callable = Callable(command.waypoint, "queue_free")
        callable.call_deferred()
        queue.erase(command)
        command.queue_free()
