@icon("res://engine/abstract_classes/behavior_tree/icons/inverter.svg")
extends Decorator

class_name InverterDecorator


func tick(action, blackboard):
    print("Flee inverter tick")
    for c in get_children():
        var response = c.tick(action, blackboard)

        if response == SUCCESS:
            return FAILURE
        if response == FAILURE:
            return SUCCESS

        return RUNNING
