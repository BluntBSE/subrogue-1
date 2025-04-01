extends GenericState
class_name OrdnanceOpenState
@warning_ignore("shadowed_variable_base_class") #Underscores are used for both internal variables and unused variables.
var ref:SonarOrdnanceUI

func stateEnter(_args:Dictionary)->void:
    ref = _reference
    #Consider adding an 'initialized' bool to the reference to avoid playing this when the game starts.
    #Or maybe playing it really slow for ultimate vibe?
    ref.anim_player.play("OrdnanceIn")
    
    

func stateExit()->void:
    ref.anim_player.play("OrdnanceOut")
