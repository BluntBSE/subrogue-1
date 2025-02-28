extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    spawn_entity_at_node(%test_node, "debug_commercial", GlobalConst.layers.FACTION_1)
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass
    


func spawn_entity_at_node(node:NavNode, type_id:String, for_faction:int):
    var entity:Entity = load("res://engine/entities/generic_entity.tscn").instantiate()
    var entity_controller:EntityController = get_node("FactionEntities")
    var is_npc:bool = GlobalConst.is_layer_player(for_faction)
    
    entity_controller.add_child(entity)
    entity.behavior.destination_node = get_tree().root.find_child("NavNode_Gibraltar", true, false)
    entity.position = node.position
    entity.unpack(type_id, for_faction)


    
