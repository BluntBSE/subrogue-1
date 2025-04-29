extends Node3D
class_name CityInteraction

var world_hovered:bool = false
signal opened_city


func _on_docking_area_body_entered(body: Entity) -> void:
    body.handle_in_docking_area(get_parent())    
    if body.played_by != null:
        var interaction_area_1:Area3D = get_node("InteractionBox1")
        #Prevent players from navigating onto the labels they should be able to click on.
        interaction_area_1.set_collision_layer_value(1, true)
    pass # Replace with function body.


func _on_interaction_box_1_mouse_entered() -> void:
    world_hovered = true
    %CityNameLabel.modulate = Color("ffffff")
    %CityDot.modulate = Color("ffffff")
    %CityRing.modulate = Color("ffffff")
    pass # Replace with function body.


func _on_interaction_box_1_mouse_exited() -> void:
    #Left clicking triggers a mouse exit, ugh.
    world_hovered = false
    var faction_color:Color = %CityNode.faction.faction_color
    %CityNameLabel.modulate = Color("ffffff")
    %CityDot.modulate = faction_color
    %CityRing.modulate = faction_color
    #Enable player navigating onto the labels they should be able to click on.

    pass # Replace with function body.


func _on_docking_area_body_exited(body: Entity) -> void:
    var body_position = body.global_transform.origin
    var distance_to_center = body.position.distance_to(global_transform.origin)

    if distance_to_center >= 3.5:
        body.handle_leave_docking_area()
        if body.played_by != null:
            var interaction_area_1:Area3D = get_node("InteractionBox1")
            interaction_area_1.set_collision_layer_value(1, true)
    else:
        pass




#The rigidbody associated with city is also par tof this
func _on_interaction_box_1_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
    if event is InputEventMouseButton:
        event as InputEventMouseButton
        if event.button_index == MOUSE_BUTTON_LEFT and event.is_released():
            
            opened_city.emit(get_parent())
            SoundManager.play_straight("ui_swoop_1", "ui")
    pass # Replace with function body.
