extends BehaviorTree

class_name BehaviorTreeRoot

#Why?
#const Blackboard = preload("res://engine/abstract_classes/behavior_tree/blackboard.gd")

@export var enabled:bool = true

@onready var blackboard = BlackBoard.new()

func _ready():
    if self.get_child_count() != 1:
        print("Behavior tree error: Root should only have one child")
        disable()
        return
        
func _process(delta:float):
    #I chose process instead of physics process because I lowered my physics frames a *lot*
    #Possibly we can throttle how often this runs to improve performance if needed
    if not enabled:
        return
        
    blackboard.bbset("delta", delta)
    self.get_child(0).tick(get_parent(), blackboard)    #???
    

func enable():
    self.enabled = true

func disable():
    self.enabled = false
    
    
    
