extends GenericState
class_name ClosedSelfState

var ref:SelfMenuRoot
var player:AnimationPlayer
func stateEnter(args:Dictionary):
    ref = _reference
    #Unlike other states, the animation for opening the self menu is
    #Governed by the player UI root because it must synchronize with other unrelated menus

    
    
