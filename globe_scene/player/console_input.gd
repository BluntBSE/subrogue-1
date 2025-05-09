extends LineEdit
class_name ConsoleInput




func spawn_entity_at_node(node:NavNode, type_id:String, for_faction:Faction):
    if get_multiplayer_authority() == 1:
        var entity:Entity = preload("res://engine/entities/generic_entity.tscn").instantiate()
        #TODO: update this to the appropriate faction entity controller
        var faction = get_tree().root.find_child("AmazonDominion", true, false)
        var entity_controller:EntityController = faction.get_node("FactionEntities")
        var is_npc:bool = GlobalConst.is_layer_player(for_faction.faction_layer)
        entity_controller.add_child(entity)
        entity.behavior.destination_node = get_tree().root.find_child("NavNode_Gibraltar", true, false)
        entity.position = node.position
        entity.unpack(type_id, for_faction, null)

func _unhandled_input(event:InputEvent):
    if event is InputEventKey and event.is_released() and event.keycode == KEY_QUOTELEFT:
        visible = !visible
    


func _on_text_submitted(new_text: String) -> void:
    var gr:GameRoot = get_tree().root.find_child("GameRoot", true, false)
    if new_text == "new target":
         var test_node = get_tree().root.find_child("test_node", true, false)
         spawn_entity_at_node(test_node, "debug_commercial", gr.factions.faction_1)       
    if new_text == "i see everything":
        see_everything()
    if new_text == "nomore":
        stop_spawning()
    if new_text == "panic":
        get_tree().root.find_child("PanicRoot", true, false).set_process(true)
        get_tree().root.find_child("PanicRoot", true, false).visible = true
        get_tree().root.find_child("PanicFilter", true, false).material.set("shader_parameter/active", true)
        SoundManager.play_straight("get_wrecked_1")
    pass # Replace with function body.



func see_everything()->void:
    var camera:Camera3D = get_tree().root.find_child("OrbitalCamera", true, false)
    for idx in range(0, 19):
        camera.set_cull_mask_value(idx+1, true)

func stop_spawning():
    get_tree().root.find_child("TSM", true, false).spawn_more = false
