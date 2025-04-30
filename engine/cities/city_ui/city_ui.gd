extends TextureRect
class_name CityUI


#You ABSOLUTELY need to replace this with a state machine once the trailer is done.

func unpack(_city:CityDef, _for_faction:Faction = null):
    %CityNameLabel.text = _city.city_name
    if _for_faction:
        %FactionLabel.text = _for_faction.name
    
    %CityDescription.text = _city.city_greeting
    pass


func show_contract_options():
    %MainOptions.visible = false
    %ContractContacts.visible = true
    %ContactActions.visible = false
    


func _on_contracts_button_button_up() -> void:
    show_contract_options()
    pass # Replace with function body.


func _on_contract_npc_button_button_up() -> void:
    %ContractContacts.visible = false
    %ContractCloseUp.visible = true
    %CityGreeting.visible = false
    %CityNameLabel.visible = false
    %FactionLabel.visible = false
    pass # Replace with function body.


func _on_accept_mission_trailer() -> void:
    %ContractContacts.visible = false
    %ContractCloseUp.visible = false
    %CityGreeting.visible = true
    %CityNameLabel.visible = true
    %FactionLabel.visible = true
    %MainOptions.visible = true
    pass # Replace with function body.
