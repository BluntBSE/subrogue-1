extends GenericState
class_name CamContextState
var ref:OrbitalCamera


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    ref.input_movement()
    pass
    
func stateEnter(_args:Dictionary)->void:
    ref = _reference
    ref.drop_context_marker(ref.hovering_over.position)


func stateHandleInput(_args:Dictionary)->void:
    var event:InputEvent = _args["event"]
    input_clicks(event)
    
    pass

func input_clicks(event:InputEvent):
    ref = _reference
    #BECAUSE we're not shift clicking or doing waypoint logic right now, this always overwrites the most recent item in the queue.
    if event.is_action_pressed("primary_action"):
        if ref.hovering_over != {}:
            if ref.hovering_over.collider.name == "ClickableSphere":
                var click_position = ref.hovering_over.position
                var click_normal = ref.hovering_over.normal
                var click_azimuth = GlobeHelpers.rads_from_position(click_position).azimuth
                var click_polar = GlobeHelpers.rads_from_position(click_position).polar
                #Create a 3D area to check for collision with to determine if a movement is finished.
                var waypoint:Vector3 = GlobeHelpers.fix_height_vector(click_position, ref.hovering_over.collider)
              

                
                var move_command := MoveCommand.new()
                move_command.start_azimuth = ref.active_entity.azimuth
                move_command.start_polar = ref.active_entity.polar
                move_command.end_azimuth = click_azimuth
                move_command.end_polar = click_polar
                move_command.tolerance = ref.active_entity.move_tolerance #Currently 0.0, intolerant.
                move_command.waypoint = waypoint
                ref.order_move.emit(move_command)

                
    if event.is_action_released("secondary_action"): #Or open_context?
        ref.state_machine.Change("navigating", {})
        ref.close_context.emit()        
