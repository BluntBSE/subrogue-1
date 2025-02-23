extends Composite

class_name SelectorComposite

func tick(actor, blackboard):
    for c in get_children():
        var response = c.tick(actor,blackboard)
         
        if response != FAILURE:
            return response
            
    return FAILURE
