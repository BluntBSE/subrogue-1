extends GenericState
class_name OnlySelfState
var ref: SelfMenuRoot
var player:AnimationPlayer


func stateEnter(args:Dictionary):
    if args["animation_required"] == true:
        print("Entered self open state")
        ref = _reference
        player = _reference.player
        player.play("self_in")
    pass
    
func stateExit():
    print("Exited self open state")
    ref = _reference
    player = _reference.player
    player.play_backwards("self_in")
    pass
