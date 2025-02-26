extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    spawn_entity_at_node(%NavNode_Miami, "debug_commercial")
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass
    


func spawn_entity_at_node(node:NavNode, type_id:String, is_player = false):
    var entity:Entity = load("res://engine/entities/generic_entity.tscn").instantiate()
    entity.is_player = is_player
    var entity_controller:EntityController = get_node("FactionEntities")
    entity.npc = true
    entity_controller.add_child(entity)
    entity.behavior.destination_node = get_tree().root.find_child("NavNode_Gibraltar", true, false)

    entity.position = node.position
    #entity.assign_to_faction(faction
    var type:EntityType = GlobalConst.entity_lib.get(type_id)
    entity.apply_entity_type(type)
    #Debug - load with an ideal path
    #var origin = get_tree().root.find_child("NavNode_Miami", true, false)
    #var dest = get_tree().root.find_child("NavNode_Gibraltar", true, false)
    #var network = get_tree().root.find_child("NavNodes", true, false)
    #var path = entity.move_bus.path_between_nodes(origin, dest, network)
    #print("Path is!", path)
    #for navnode:NavNode in path:
        #navnode.unpack()
    
    #waypoints_from_nodes(entity, path)
    print("Activating entity AI")

    
func waypoints_from_nodes(entity:Entity, nodes:Array):
    for node:NavNode in nodes:
        var command:MoveCommand = GlobeHelpers.generate_move_command(entity, node.position)
        var entity_controller:EntityController = get_node("FactionEntities")
        entity_controller.relay_enqueue_move(command)
      


    

    pass
