extends EventBus
class_name EntityMoveBus
#Yuck
@onready var entity:Entity = get_parent()
#@onready var player:Player = entity.get_parent().get_parent()
@onready var entity_controller:EntityController = get_parent().get_parent()
var max_size = 5 #Number of waypoints that can be queued up.

func _ready()->void:
    entity_controller.order_move.connect(handle_order_move)
    entity_controller.enqueue_move.connect(handle_enqueue_move)
    


func handle_order_move(command:MoveCommand)->void:
    #Make sure the move command is for this entity.
    if command.entity == entity:
        add(command)
        command.finished.connect(handle_finished)
        purge_old_waypoints()


    
func handle_enqueue_move(command:MoveCommand)->void:
    if command.entity == entity:
        add(command)
        command.finished.connect(handle_finished)    

func add(command:Command)->void:
    queue.append(command)
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
        var frontier:Array = []
        var command: MoveCommand = queue[1]
        var callable: Callable = Callable(command.waypoint, "queue_free")
        callable.call_deferred()
        queue.erase(command)
        command.queue_free()
        
        
        


func path_between_nodes(point_a: NavNode, point_b: NavNode, network: Node3D) -> Array:
    var open_set = []
    var came_from = {}
    var cost_so_far = {}
    
    open_set.append({"cost": 0, "node": point_a})
    cost_so_far[point_a] = 0
    
    #TODO: Doing this is probably stupidly expensive. We should learn how to implement max heaps.
    while open_set.size() > 0:
        open_set.sort_custom(func(a, b): a["cost"] < b["cost"]) # Sort the open set by cost
        var current = open_set.pop_front()["node"]
        
        if current == point_b:
            break
        
        for neighbor in current.neighbors:
            var new_cost = cost_so_far[current] + (current.position - neighbor.position).length()
            
            if not cost_so_far.has(neighbor) or new_cost < cost_so_far[neighbor]:
                cost_so_far[neighbor] = new_cost
                open_set.append({"cost": new_cost, "node": neighbor})
                came_from[neighbor] = current
    
    return reconstruct_path(came_from, point_a, point_b)

func reconstruct_path(came_from: Dictionary, start: NavNode, goal: NavNode) -> Array:
    var path = []
    var current = goal
    
    while current != start:
        path.append(current)
        current = came_from[current]
    
    path.append(start)
    path.reverse()
    

    return path
