@icon("res://engine/abstract_classes/behavior_tree/icons/selector.svg")
extends Composite

class_name SelectorComposite

## NOTE: In the context of vessel AI, different AI profiles are basically represented by promoting
## Given branches


func tick(actor, blackboard):
    for c in get_children():
        if c is not NoteLeaf:
            var response = c.tick(actor,blackboard)
            
            if response != FAILURE:
                return response
            
    return FAILURE
