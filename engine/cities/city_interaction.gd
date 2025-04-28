extends Node3D


func _on_docking_area_body_entered(body: Node3D) -> void:
    print("Body entered:", body)
    pass # Replace with function body.


func _on_interaction_box_1_mouse_entered() -> void:
    print("Moused over Miami")
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
