class_name BehaviorType

"""
All entities have access to the same behavior branches. 
They differ based on the order in which they choose to attempt branches.
A behavior type defines the order.

var behavior_order = [
    EntityBehavior.core_behaviors.MoveToDestination,
    EntityBehavior.core_behaviors.FleeThreat, #If you want to implement bribes, they go in flee
    EntityBehavior.core_behaviors.STOP #Represents the end of the AI we have programmed for this
]
"""

var behavior_order = []
