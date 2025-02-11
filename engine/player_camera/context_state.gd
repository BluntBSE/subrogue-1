extends GenericState
class_name CamContextState
var ref:OrbitalCamera


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    ref.input_movement()
    pass
    
func stateEnter(_args:Dictionary)->void:
    ref = _reference
    ref.drop_context_marker(ref.hovering_over.position)


func stateHandleInput(_args:Dictionary)->void:
    var event:InputEvent = _args["event"]
    input_clicks(event)
    
    pass

func input_clicks(event:InputEvent):
    var ref:OrbitalCamera = _reference
    #BECAUSE we're not shift clicking or doing waypoint logic right now, this always overwrites the most recent item in the queue.
    if event.is_action_released("primary_action"):
        print("Left mouse clicked while in the context menu")
        pass
                
    if event.is_action_released("secondary_action"): #Or open_context?
        ref.state_machine.Change("navigating", {})
        pass
