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
        #"Behavior tree error: Root should only have one child"
        disable()
        return

var frames:float = 0.0
func _process(_delta:float):
    frames += 1.0 #NOT delta because we're counting frames. Frames are once per process.
    if frames >= get_parent().every_x_frames:
        frames = 0.0
    #I chose process instead of physics process because I lowered my physics frames a *lot*
    #Possibly we can throttle how often this runs to improve performance if needed
        if not enabled:
            return
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
    

#BLACKBOARD VARIABLES TO KEEP TRACK OF
#"recently_fled":bool

    
