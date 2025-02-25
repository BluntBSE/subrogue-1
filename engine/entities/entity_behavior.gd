extends Node
class_name EntityBehavior

"""
This node is the parent of the behavior tree associated with the entity.
All entities have the same behavior tree when instantiated, but
this node is responsible for promoting, demoting, and locking branches to match
a given behavior profile.
"""
enum core_behaviors {MoveToDestination, Patrol, EscortTarget, FleeTarget, FindTarget, HailTarget, SeekDestroy, SeekHail, FleeSpecific, FindWrecks, SalvageWreck, SalvageSpecific}
#NAVIGATING
#The range at which a move order will be considered complete
var move_tolerance:float = 1.0
#Use position when entities are moving towards specific entities (e.g: towards the player)
var move_position:Vector3
#Use node when entities are moving to a known place in the world
var move_node:NavNode


#TARGETING
var allies := []
#var neutral := [] #Is this necessary? If not enemy or friend, is neutral.
var friends := []
var investigating:Node3D = null
var targeting:Node3D = null
var escorting:Node3D = null
var seeking:Node3D = null
# How confident this entity is in its strength. Compared to the player's reputation, or player's capabilities
# This determines
var chutzpah:float = 100.0


var profile = null #BehaviorProfile controls the order of the nodes.


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass
