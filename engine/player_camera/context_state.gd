extends GenericState
class_name CamContextState
var ref:OrbitalCamera


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass
    
func stateEnter(_args:Dictionary)->void:
    ref = _reference
    ref.drop_context_marker(ref.hovering_over.position)


func stateHandleInput(_args:Dictionary)->void:
    ref = _reference
    input_clicks()
    ref.input_movement()
    
    pass

func input_clicks():
    var ref:OrbitalCamera = _reference
    #BECAUSE we're not shift clicking or doing waypoint logic right now, this always overwrites the most recent item in the queue.
    if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
        print("Left mouse clicked while in the context menu")
        pass
                
    if Input.is_action_just_released("open_context"):
        ref.state_machine.Change("navigating", {})
        pass
