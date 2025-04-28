extends Node3D
class_name CityInteraction

var world_hovered:bool = false
signal opened_city


func _on_docking_area_body_entered(body: Entity) -> void:
    body.handle_in_docking_area(get_parent())    
    pass # Replace with function body.


func _on_interaction_box_1_mouse_entered() -> void:
    world_hovered = true
    %CityNameLabel.modulate = Color("ffffff")
    %CityDot.modulate = Color("ffffff")
    %CityRing.modulate = Color("ffffff")
    pass # Replace with function body.


func _on_interaction_box_1_mouse_exited() -> void:
    world_hovered = false
    var faction_color:Color = %CityNode.faction.faction_color
    %CityNameLabel.modulate = Color("ffffff")
    %CityDot.modulate = faction_color
    %CityRing.modulate = faction_color
    pass # Replace with function body.


func _on_docking_area_body_exited(body: Entity) -> void:
    var body_position = body.global_transform.origin
    var distance_to_center = body.position.distance_to(global_transform.origin)

    if distance_to_center >= 3.5:
        body.handle_leave_docking_area()
    else:
        pass


func _input(event:InputEvent):
    if event is InputEventMouseButton:
        if event.is_action_released("primary_action"):
            opened_city.emit(get_parent())
