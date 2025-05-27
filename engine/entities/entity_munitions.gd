extends Node
class_name EntityMunitions

var active_munition:String = "manta_torpedo"#Munition id for munitin_by_id
var controller:EntityController #We assume that all entities and munitions are the immediate children of the controller nodes
var entity:Entity


func _ready():
    controller = get_parent().get_parent()

func launch_munition(args:Dictionary):
    var munition:Munition = args.munition
    var start_position:Vector3 = args.start_position
    var target_position:Vector3 = args.target_position
    munition.fired_from = args.originating_entity
    controller.add_child(munition)
    #TODO: Really got set this up into a better unpack...
    munition.atts.display_name = munition.display_name
    
    munition.position = start_position #Global?
    var command = GlobeHelpers.generate_move_command(munition, target_position)
    controller.order_move.emit(command)
    pass   
    
func handle_launch(args:Dictionary):
    pass
