extends Node
class_name Command
signal finished

func do()->void:
    #Pure virtual
    pass
    
func undo()->void:
    #Pure virtual
    pass
    
func is_finished()->void:
    finished.emit()
    
