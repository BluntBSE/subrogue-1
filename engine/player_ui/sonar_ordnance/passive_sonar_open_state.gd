extends GenericState
class_name PassiveSonarOpenState
@warning_ignore("shadowed_variable_base_class") #Underscores are used for both internal variables and unused variables.
var ref:SonarOrdnanceUI

func stateEnter(_args:Dictionary)->void:
    ref = _reference
    ref.active_index = 1
    #Consider adding an 'initialized' bool to the reference to avoid playing this when the game starts.
    #Or maybe playing it really slow for ultimate vibe?
    ref.anim_player.queue("PassiveSonarIn")
    ref.adjust_tab_z()
    ref.adjust_tab_colors()
    ref.sonar_ordnance_ui_state.emit(ref.state_machine._current_state_id)

    pass
    
    

func stateExit()->void:
    ref.anim_player.queue("PassiveSonarOut")
