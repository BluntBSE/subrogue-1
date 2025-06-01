extends GenericState
class_name ViewingContractsState

var _ref:CityUI

func stateUpdate(_dt: float) -> void:
    pass
func stateHandleInput(_args:Dictionary) -> void :
    pass
    
func stateEnter(_args: Dictionary) -> void:
    var npcs:Array[CityNPC] = _args.npcs
    #Finding child isn't great practice but the UI is totally in the air, sue me.
    _ref.find_child("MainOptions", true, false).visible = false
    _ref.find_child("ContractContacts", true, false).visible = true
    for npc:CityNPC in npcs:
        render_npc(npc)
    
func render_npc(npc:CityNPC):
    
    pass 
   
    

func stateExit() -> void:
    #Play animation player because the only way to exit the hidden state is when you
    #Open from docks, right?
    #ACTUALLY this is current handled by the player UI root which I don't mind because
    #The animation is indeed relative to all the other UI elements...
    #We'll see!!
    pass
