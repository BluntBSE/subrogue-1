extends GenericState
class_name ViewingContractsState

var _ref:CityUI

func stateUpdate(_dt: float) -> void:
    pass
func stateHandleInput(_args:Dictionary) -> void :
    pass
    
func stateEnter(_args: Dictionary) -> void:
    var npcs:Array[CityNPC] = _args.npcs
    _ref = _reference
    #Finding child isn't great practice but the UI is totally in the air, sue me.
    _ref.find_child("ContractContacts", true, false).visible = true
    var contracts_vbox:VBoxContainer = _ref.find_child("ContractContacts",true,false)
    for child in contracts_vbox.get_children():
        child.queue_free()
        
    for npc:CityNPC in npcs:
        render_npc(npc, contracts_vbox)
        
func stateExit():
    print("Exiting ViewingContractsState")
    _ref.find_child("ContractContacts", true, false).visible = false

func render_npc(npc:CityNPC, at:Control):
    var npc_button:ContractNPCButton = preload("res://engine/cities/city_npc/contract_npc_button.tscn").instantiate()
    at.add_child(npc_button)
    npc_button.unpack(npc)
    #For now, NPCs only generate one quest apiece loaded upon ready.
    
    npc_button.button_up.connect(handle_npc_button_up.bind(npc.quests[0]))

   
func handle_npc_button_up(quest:Quest):
    print("NPC BUTTON UP, with quest: ", quest)
    _ref.state_machine.Change("ContractCloseup", {"quest":quest})
    pass
