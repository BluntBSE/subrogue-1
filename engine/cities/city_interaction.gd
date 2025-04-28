extends Node3D


func _on_docking_area_body_entered(body: Entity) -> void:
    body.handle_in_docking_area()    
    pass # Replace with function body.


func _on_interaction_box_1_mouse_entered() -> void:
    %CityNameLabel.modulate = Color("ffffff")
    %CityDot.modulate = Color("ffffff")
    %CityRing.modulate = Color("ffffff")
    pass # Replace with function body.


func _on_interaction_box_1_mouse_exited() -> void:
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
