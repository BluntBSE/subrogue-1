extends Control
class_name SelfMenuRoot
var open:bool = false
var vessel_open = false
signal toggle_self_menu #We use a signal because the selfmenu root will become its own scene.

@onready var player:AnimationPlayer = %SelfMenuAnimationPlayer
@onready var ui_root:PlayerUIRoot = get_parent() #We do some disconnecting/reconnecting of signals because we change a button's function.
#Probably gonna need to add a state machine tbh
var state_machine:StateMachine = StateMachine.new()

func _ready():
    state_machine.Add("closed", ClosedSelfState.new(self, {}))
    state_machine.Add("onlyself", OnlySelfState.new(self, {}))
    state_machine.Add("vessel", VesselState.new(self, {}))
    state_machine.Change("onlyself", {})
    #player.play_backwards("vessel_in") #Idk why :(

func _on_self_menu_toggle_button_button_up() -> void:
    toggle_open()
    if open == true:
        state_machine.Change("onlyself", {})
    else:
        state_machine.Change("closed", {})

func _on_vessel_button_button_up() -> void:
    if state_machine._current_state_id != "vessel":
        state_machine.Change("vessel", {})
    else:
        state_machine.Change("onlyself", {})
        

    pass # Replace with function body.

func toggle_open():
    open = !open
    print("toggle open emitting ", open)
    toggle_self_menu.emit(open)
