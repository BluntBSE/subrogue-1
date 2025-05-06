extends GenericState
class_name VesselState

var ref: SelfMenuRoot
var player:AnimationPlayer


func stateEnter(args:Dictionary):
    print("Entered vessel state")
    ref = _reference
    player = _reference.player
    player.play("vessel_in")
    pass

func stateExit():
    print("Reversing vessel_in")
    player.play_backwards("vessel_in")
