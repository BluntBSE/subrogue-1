extends CommandBus
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
        purge_waypoints()
        add(command)
        command.finished.connect(handle_finished)



    
func handle_enqueue_move(command:MoveCommand)->void:
    if command.entity == entity:
        add(command)
        command.finished.connect(handle_finished)    

func add(command:Command)->void:
    queue.append(command)
    pass


func handle_finished(command:MoveCommand):
    #command.waypoint.queue_free()
    queue.erase(command)
    command.queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass
    

  
func purge_old_waypoints():
    # For allowing the active move command to be continually updated with mouse position
    # Erase for every member of the queue that is not at queue[0]
    #Im sure I had a good reason for not just making the queue = []...
    
    while queue.size() > 1:
        var command: MoveCommand = queue[0]
        #var callable: Callable = Callable(command.waypoint, "queue_free")
       # callable.call_deferred()
        queue.erase(command)
        command.queue_free()
        

func purge_waypoints():
    for command in queue:
       # var callable: Callable = Callable(command.waypoint, "queue_free")
        #callable.call_deferred()
        queue.erase(command)
        command.queue_free()
    queue = []
        

"""
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
"""

func path_between_nodes(point_a: NavNode, point_b: NavNode, network: Node3D) -> Array:
    var open_set = PriorityQueue.new()
    var came_from = {}
    var cost_so_far = {}
    
    # Add the starting node to the open set with a cost of 0
    open_set.push(point_a, 0)
    cost_so_far[point_a] = 0
    
    while not open_set.is_empty():
        # Get the node with the lowest cost
        var current = open_set.pop()
        
        if current == point_b:
            break
        
        for neighbor in current.neighbors:
            var new_cost = cost_so_far[current] + (current.position - neighbor.position).length()
            
            if not cost_so_far.has(neighbor) or new_cost < cost_so_far[neighbor]:
                cost_so_far[neighbor] = new_cost
                came_from[neighbor] = current
                open_set.push(neighbor, new_cost)
    
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


func waypoints_from_nodes(nodes:Array):
    for node:NavNode in nodes:
        var command:MoveCommand = GlobeHelpers.generate_move_command(entity, node.position)
        
        #entity_controller.relay_enqueue_move(command)#Weird, but...Whatever
        handle_enqueue_move(command)
    pass

func find_closest_node()->NavNode:
    #Might be better to implement a sphere-marching approach
    #TODO: Fix this if it performs badly
    var closest_node:NavNode
    for node in get_tree().get_nodes_in_group("nav_nodes"):
        if closest_node == null:
            closest_node = node
        if (entity.position-node.position).length() < (entity.position - closest_node.position).length():
            closest_node = node
            
    return closest_node


func order_destination_path():
    purge_waypoints()
    var destination = entity.behavior.destination_node
    var path = path_between_nodes(find_closest_node(), destination, get_tree().root.find_child("NavNodes", true, false))
    waypoints_from_nodes(path) 
