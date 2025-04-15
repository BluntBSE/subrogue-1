extends Node3D
class_name EntityController

var player:Node3D
signal order_move
signal enqueue_move

func relay_order_move(command:MoveCommand)->void:
    order_move.emit(command)


func relay_enqueue_move(command:MoveCommand):
    enqueue_move.emit(command)

func launch_munition(args:Dictionary):
    var munition:Munition = args.munition
    var start_position:Vector3 = args.start_position
    var target_position:Vector3 = args.target_position
    munition.fired_from = args.originating_entity
    munition.name = "munition_"+str(args.originating_entity)+str(randi()%9999)
    add_child(munition)
    munition.position = start_position #Global?
    var command = GlobeHelpers.generate_move_command(munition, target_position)
    order_move.emit(command)
    pass   
