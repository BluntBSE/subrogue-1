extends Node3D
class_name Faction
@export var faction_id = GlobalConst.layers.FACTION_1

@export var faction_color:Color = Color()
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    #DEBUG SPAWNER. Eventually we need to fill out the appropriate factions
    if faction_id == GlobalConst.layers.FACTION_1:
        spawn_entity_at_node(%test_node, "debug_commercial", GlobalConst.layers.FACTION_1)
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass
    


func spawn_entity_at_node(node:NavNode, type_id:String, for_faction:int):
    if get_multiplayer_authority() == 1:
        var entity:Entity = load("res://engine/entities/generic_entity.tscn").instantiate()
        #TODO: update this to the appropriate faction entity controller
        var entity_controller:EntityController = get_node("FactionEntities")
        var is_npc:bool = GlobalConst.is_layer_player(for_faction)
        entity_controller.add_child(entity)
        entity.behavior.destination_node = get_tree().root.find_child("NavNode_Gibraltar", true, false)
        entity.position = node.position
        entity.unpack(type_id, for_faction)


    
