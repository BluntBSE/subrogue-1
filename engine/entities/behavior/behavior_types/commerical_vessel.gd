extends BehaviorType
class_name CommercialVesselType


# Called when the node enters the scene tree for the first time.


func _init()->void:
    print("Hello from commercialvessel type")
    behavior_order = [
        EntityBehavior.core_behaviors.MoveToDestination,
        EntityBehavior.core_behaviors.FleeThreat, #If you want to implement bribes, they go in flee
        EntityBehavior.core_behaviors.STOP #Represents the end of the AI we have programmed for this
    ]
    pass
