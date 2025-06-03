extends GenericState
class_name CityUIHiddenState
var _ref:CityUI

func stateUpdate(_dt: float) -> void:
    pass
func stateHandleInput(_args:Dictionary) -> void :
    pass
func stateEnter(_args: Dictionary) -> void:
    _ref = _reference
    _ref.visible = false
    pass
func stateExit() -> void:
    #Play animation player because the only way to exit the hidden state is when you
    #Open from docks, right?
    #ACTUALLY this is current handled by the player UI root which I don't mind because
    #The animation is indeed relative to all the other UI elements...
    #We'll see!!
    pass
