extends TextureRect
class_name CityUI

var active_city:City
var state_machine:StateMachine

#STATES == city_main, #viewing_contracts, #contract_closeup
func _ready():
    state_machine = StateMachine.new()
    #state_machine.Add("Hidden", CityUIHiddenState.new(self,{})) #Probably enough to be governed by CityUIRoot, which belongs to PlayerUIRoot
    state_machine.Add("CityMain", CityMainState.new(self,{})) #This one might actually take args, even. Won't that be novel.
    state_machine.Add("ViewingContracts", ViewingContractsState.new(self,{}))
    state_machine.Add("ContractCloseup", ContractCloseupState.new(self,{}))
    #state_machine.Change("Hidden", {})
    
#You ABSOLUTELY need to replace this with a state machine once the trailer is done.

func unpack(_city:City, _for_faction:Faction = null):
    active_city = _city #We would need the actual city if we wanted to move.
    state_machine.Change("CityMain", {"active_city":active_city})


func show_contract_options():
    state_machine.Change("ViewingContracts", {"npcs":active_city.npcs})
    


func _on_contracts_button_button_up() -> void:
    print("ACTIVE CITY NPCS: ", active_city.npcs)
    show_contract_options()


func _on_contract_npc_button_button_up() -> void:
    %ContractContacts.visible = false
    %ContractCloseUp.visible = true
    %CityGreeting.visible = false
    %CityNameLabel.visible = false
    %FactionLabel.visible = false


func _on_accept_mission_trailer() -> void:
    %ContractContacts.visible = false
    %ContractCloseUp.visible = false
    %CityGreeting.visible = true
    %CityNameLabel.visible = true
    %FactionLabel.visible = true
    %MainOptions.visible = true
    pass # Replace with function body.
