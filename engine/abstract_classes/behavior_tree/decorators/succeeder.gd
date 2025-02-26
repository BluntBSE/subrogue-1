@icon("res://engine/abstract_classes/behavior_tree/icons/succeed.svg")
extends Decorator

class_name AlwaysSucceedDecorator


func tick(action, blackboard):
    for c in get_children():
        var response = c.tick(action, blackboard)
        if response == RUNNING:
            return RUNNING
        return SUCCESS
