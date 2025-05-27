@icon("res://engine/abstract_classes/behavior_tree/icons/selector.svg")
extends Composite

class_name SelectorComposite

## NOTE: In the context of vessel AI, different AI profiles are basically represented by promoting
## Given branches


func tick(actor, blackboard):
    print("Hello from tick for ", self.name)
    for c in get_children():
        if c is not NoteLeaf:
            var response = c.tick(actor,blackboard)
            
            if response != FAILURE:
                print("Success in selector", self.name)
                return response
    print("Failure in selector", self.name)
    return FAILURE
