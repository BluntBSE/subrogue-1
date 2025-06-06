extends Composite

class_name Sequencer2

#The idea here is that it won't proceed along the sequence if it gets a failure.
#Therefore, the order of the child nodes matters.

func tick(actor, blackboard):
    for c in get_children():
        if c is not NoteLeaf:
            var response = c.tick(actor, blackboard)

            if response != SUCCESS:
                return response
    return SUCCESS
