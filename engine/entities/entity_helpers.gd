extends Node
class_name EntityHelpers

static func spawn_entity_at_node(node:NavNode, type_id:String, for_faction:Faction, with_name = null):
        var entity:Entity = preload("res://engine/entities/generic_entity.tscn").instantiate()
        #TODO: update this to the appropriate faction entity controller
        var entity_controller:EntityController = for_faction.get_node("FactionEntities")
        var is_npc:bool = GlobalConst.is_layer_player(for_faction.faction_layer)
        entity_controller.add_child(entity)
        #entity.behavior.destination_node = node.get_tree().root.find_child("NavNode_Gibraltar", true, false)
        entity.position = node.position
        #with_name can be "Null". If it is, the entity unpack will randomly generate one. 
        
        entity.unpack(type_id, for_faction, with_name)
        return entity
        
        
