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
    entity_controller.add_child(entity)
    entity.position = node.position
    #entity.assign_to_faction(faction
    var type:EntityType = GlobalConst.entity_lib.get(type_id)
    entity.apply_entity_type(type)

    pass
