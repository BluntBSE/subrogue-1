extends GenericState
class_name CityMainState

var _ref:CityUI

func stateUpdate(_dt: float) -> void:
    pass
func stateHandleInput(_args:Dictionary) -> void :
    pass
    
func stateEnter(_args: Dictionary) -> void:
    _ref = _reference
    _ref.visible = true
    var city:City = _args.active_city
    var city_def:CityDef = city.city_def
    var faction_string:String = city.faction.display_name
    _ref.find_child("CityMain", true, false).visible = true
    _ref.get_tree().root.find_child("FactionLabel",true,false).visible = true
    _ref.get_tree().root.find_child("CityNameLabel",true,false).visible = true
    _ref.find_child("FactionLabel", true, false).text = faction_string
    _ref.find_child("CityNameLabel", true, false).text = city_def.city_name
    _ref.find_child("CityDescription", true, false).text = city_def.city_greeting
    _ref.get_tree().root.find_child("CityGreeting",true,false).visible = true

    
    

func stateExit() -> void:
    _ref.find_child("MainOptions", true, false).visible = false
    pass
