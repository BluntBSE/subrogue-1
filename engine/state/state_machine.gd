extends Node
class_name StateMachine

var _stateDict:Dictionary = {}
var _current:GenericState = GenericState.new(self, {})
var _prev_id:String
var _prev_args:Dictionary
var _current_state_id:String = ""
func getCurrent() -> GenericState:
    return _current
func Add(state_id:String, state:GenericState) -> void:
    _stateDict[state_id] = state
func Remove(state_id:String) -> void:
    _stateDict.erase(state_id)
func Clear() -> void:
    _stateDict = {}
func Change(state_id:String, args:Dictionary) -> void:
    _prev_args = args
    _prev_id = _current_state_id
    _current.stateExit()
    var next:GenericState = _stateDict[state_id]
    _current_state_id = state_id
    next.stateEnter(args)
    _current = next
    #_current_state_id = state_id -- We moved this earlier to make it possible to emit the state we're about to enter
func Revert()->void:
    #TODO: Currently broken
    var temp_id:String = _current_state_id
    Change(_prev_id, _prev_args)


#To call any parent functionality (presently none), call super()

func stateUpdate(dt:float) -> void:
    _current.stateUpdate(dt)



func handleInput(args:Dictionary) -> void:
    _current.stateHandleInput(args)




# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta:float) -> void:
    pass
