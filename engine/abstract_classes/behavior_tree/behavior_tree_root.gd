@icon("res://engine/abstract_classes/behavior_tree/icons/tree.svg")
extends BehaviorTree

class_name BehaviorTreeRoot

#Why?
#const Blackboard = preload("res://engine/abstract_classes/behavior_tree/blackboard.gd")

#Enable only on AI controlled entities
@export var enabled:bool = false

@onready var blackboard = BlackBoard.new()

func _ready():
    if self.get_child_count() != 1:
        print("Behavior tree error: Root should only have one child")
        disable()
        return

var tick_increment = 0.0
var tick_speed = 5.0
func _process(delta:float):
    #I chose process instead of physics process because I lowered my physics frames a *lot*
    #Possibly we can throttle how often this runs to improve performance if needed
    if not enabled:
        return
    blackboard.bbset("delta", delta)
    var entity = get_parent().get_parent()
    self.get_child(0).tick(entity, blackboard)    #??? I think this means "Make the immediately following composite accept the parent of this node as the thing to which tick is applied
    #Translates to:
    #selectorcomposite.tick(agent, blackboard)
    #In other words, the node to which this tree is appended is the "actor" for all children.
    #This node always expects to be part of a tree that looks like Entity->EntityBehavior->BehaviorTreeRoot(this node)
func enable():
    self.enabled = true

func disable():
    self.enabled = false
    
    
    
