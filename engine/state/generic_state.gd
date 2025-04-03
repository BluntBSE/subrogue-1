extends Node
class_name GenericState

var _reference: Node
var state_args: Dictionary

func stateUpdate(_dt: float) -> void:
    pass
func stateHandleInput(_args:Dictionary) -> void :
    pass
func stateEnter(_args: Dictionary) -> void:
    pass
func stateExit() -> void:
    pass

#This is called when we do State.new(self, args.) It allows a reference to the parent node to be passed around.
func _init(reference: Node, args: Dictionary) -> void:
    _reference = reference
    state_args = args
    unpack(args)


#This method is overwritten by implementations. It usually is used to unpack things in _args to assign to local variables
func unpack(args:Dictionary) -> void:
    #Example
    #_sprite = args.sprite
    pass

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta:float) -> void:
    pass
