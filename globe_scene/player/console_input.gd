extends LineEdit
class_name ConsoleInput




func spawn_entity_at_node(node:NavNode, type_id:String, for_faction:int):
    if get_multiplayer_authority() == 1:
        var entity:Entity = preload("res://engine/entities/generic_entity.tscn").instantiate()
        #TODO: update this to the appropriate faction entity controller
        var faction = get_tree().root.find_child("AmazonDominion", true, false)
        var entity_controller:EntityController = faction.get_node("FactionEntities")
        var is_npc:bool = GlobalConst.is_layer_player(for_faction)
        entity_controller.add_child(entity)
        entity.behavior.destination_node = get_tree().root.find_child("NavNode_Gibraltar", true, false)
        entity.position = node.position
        entity.unpack(type_id, for_faction, null)

func _unhandled_input(event:InputEvent):
    if event is InputEventKey and event.is_released() and event.keycode == KEY_QUOTELEFT:
        visible = !visible
    


func _on_text_submitted(new_text: String) -> void:
    if new_text == "new target":
         var test_node = get_tree().root.find_child("test_node", true, false)
         spawn_entity_at_node(test_node, "debug_commercial", GlobalConst.layers.FACTION_1)       
    pass # Replace with function body.
