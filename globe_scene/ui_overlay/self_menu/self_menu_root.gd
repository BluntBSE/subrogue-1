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
    #Is it okay to have a null state at the start? It causes no problems yet, but might be worth keeping track of.

    
    #Should probably just merge this with the child scene after con
    var VSB:TextureButton = find_child("VesselButton", true, false)
    VSB.button_up.connect(_on_vessel_button_button_up)
    

func _on_self_menu_toggle_button_button_up() -> void:
    toggle_open()
    if open == true:
        state_machine.Change("onlyself", {"animation_required": true})
    else:
        state_machine.Change("closed", {})

func _on_vessel_button_button_up() -> void:
    if state_machine._current_state_id != "vessel":
        state_machine.Change("vessel", {})
    else:
        state_machine.Change("onlyself", {"animation_required":false})
        

    pass # Replace with function body.

func toggle_open():
    print("Toggle open opened")
    open = !open
    print("toggle open emitting ", open)
    toggle_self_menu.emit(open)
