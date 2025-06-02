extends GenericState
class_name ContractCloseupState
var quest:Quest
var _ref:CityUI

func stateUpdate(_dt: float) -> void:
    pass
func stateHandleInput(_args:Dictionary) -> void :
    pass
    
func stateEnter(_args: Dictionary) -> void:
    print("Hello from ContractCloseupState!")
    _ref = _reference
    _ref.get_tree().root.find_child("CityGreeting",true,false).visible = false
    _ref.get_tree().root.find_child("FactionLabel",true,false).visible = false
    _ref.get_tree().root.find_child("FactionLabel",true,false).visible = false
    _ref.get_tree().root.find_child("CityNameLabel",true,false).visible = false
    _ref.get_tree().root.find_child("ContractCloseUp",true,false).visible = true

    quest = _args.quest
    render_quest(quest)
    

func render_quest(_quest:Quest):
    _ref.get_tree().root.find_child("MissionDetailsSubLabel",true,false).text = quest.display_name
   
    pass    
    

func stateExit():
    pass
