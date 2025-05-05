extends GenericState
class_name VesselState

var ref: SelfMenuRoot
var player:AnimationPlayer


func stateEnter(args:Dictionary):
    ref = _reference
    player = _reference.player
    player.play("vessel_in")
    pass

func stateExit():
    player.play_backwards("vessel_in")
