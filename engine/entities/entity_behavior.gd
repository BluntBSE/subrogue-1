extends Node
class_name EntityBehavior

"""
This node is the parent of the behavior tree associated with the entity.
All entities have the same behavior tree when instantiated, but
this node is responsible for promoting, demoting, and locking branches to match
a given behavior profile.
"""

        
#NAVIGATING
#Use node when entities are moving to a known place in the world
var destination_node:NavNode
var entity:Entity
var every_x_frames = 12 # 60 /12 = 5 times per second. More than enough for AI


#TARGETING
var allies := []
#var neutral := [] #Is this necessary? If not enemy or friend, is neutral.
var friends := []
var investigating:Node3D = null
var targeting:Node3D = null
var escorting:Node3D = null
var seeking:Node3D = null
# How confident this entity is in its strength. Compared to the player's reputation, or player's capabilities
var chutzpah:float = 100.0
@onready var behavior_tree = get_child(0)
var enabled:bool = false:
    set(value):
        enabled = value
        behavior_tree.enabled = value

var behavior_profile = null #BehaviorProfile controls the order of the nodes.


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    entity = get_parent()
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass

func enable():
    print("Hello from enable!")
    behavior_tree.enable()
    if not behavior_profile:
        print("I did not have a profile")
        apply_behavior_type(entity.atts.type.behavior_type)
    
func disable():
    behavior_tree.disable()


func apply_behavior_type(type:BehaviorType):
    print("Hello from apply behavior type")
    behavior_profile = type
    print("Type applied was: ", type)
    var core_behaviors = %MainSelector.get_children()
    print("WTF? ", type.behavior_dict)
    var keys = type.behavior_dict.keys()
    print("Core behaviors: ")
    print(core_behaviors)
    
    print("Keys:")
    print(keys)
    for behavior:Node in core_behaviors:
        if behavior.name not in keys:
            print("Checking for ", behavior.name, " in ", keys)
            behavior.queue_free()
    
    for branch in keys:
        for behavior:Node in core_behaviors:
            if branch == behavior.name:
                %MainSelector.move_child(behavior, type.behavior_dict[branch])
    #Do we need any kind of fallback or handling of unused branches? Frankly you could probably delete them.
    #Let's do that. We now delete at the top of this function.
        pass
