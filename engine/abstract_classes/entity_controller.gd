extends Node3D
class_name EntityController

var player:Node3D
signal order_move
signal enqueue_move

func relay_order_move(command:MoveCommand)->void:
    order_move.emit(command)


func relay_enqueue_move(command:MoveCommand):
    enqueue_move.emit(command)
