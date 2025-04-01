extends TextureRect
class_name SonarOrdnanceUI

var state_machine:StateMachine
@onready var anim_player:AnimationPlayer = %SonarOrdnancePlayer

var dark_2_color:Color
var dark_1_color:Color
var active_color:Color
var normal_outline:Color
var highlight_outline:Color
var highlight_color:Color

func _ready()->void:
    state_machine = StateMachine.new()
    state_machine.Add("ActiveSonarOpen", ActiveSonarOpenState.new(self,{}))
    state_machine.Add("PassiveSonarOpen", PassiveSonarOpenState.new(self,{}))
    state_machine.Add("OrdnanceOpen", OrdnanceOpenState.new(self,{}))
    #TransitioningState? Let's try to avoid it si podemos.
    state_machine.Change("ActiveSonarOpen", {})
    
    
func _process(delta:float)->void:
    #Probably not necessary yet.
    state_machine.stateUpdate(delta)
