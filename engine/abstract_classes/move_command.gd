extends Command
class_name MoveCommand
var anchor:Node3D #Moving relative to what object? We're on orbs here, so this is the main planet by default.
var entity:Node3D
var start_azimuth:float
var start_polar:float
var end_azimuth:float
var end_polar:float
var tolerance:float
var height:float #consider making a global constant. It's 5.0 everywhere.
var waypoint:Vector3 #Entity checks if the waypoint is very near to declare a move finished.

func do()->void:
    #Pure virtual
    pass
    
func undo()->void:
    #Pure virtual
    pass
    
func is_finished()->void:
    finished.emit(self)
    
