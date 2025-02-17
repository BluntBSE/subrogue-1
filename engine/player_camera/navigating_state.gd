extends GenericState
class_name CamNavState #When the player is doing nothing in particular, left clicks are assumed to move their sub, right lcicks open context.
var ref:OrbitalCamera


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass
    
func stateHandleInput(_args:Dictionary)->void:
    #Takes in _unhandled_input from ref.
    var event:InputEvent = _args["event"]
    input_clicks(event)

            



func input_clicks(event:InputEvent):
    var ref:OrbitalCamera = _reference
    #BECAUSE we're not shift clicking or doing waypoint logic right now, this always overwrites the most recent item in the queue.
    if Input.is_action_pressed("primary_action"):
        if ref.hovering_over != {}:
            if ref.hovering_over.collider.name == "ClickableSphere":
                var click_position = ref.hovering_over.position
                var click_normal = ref.hovering_over.normal
                var click_azimuth = GlobeHelpers.rads_from_position(click_position).azimuth
                var click_polar = GlobeHelpers.rads_from_position(click_position).polar
                #Create a 3D area to check for collision with to determine if a movement is finished.
                var waypoint:Area3D = Area3D.new()
                var wp_collider := CollisionShape3D.new()
                var wp_shape := SphereShape3D.new() #default radius of 0.5. If we use tolerance, this might be what we assign it to.
                #Consider making these waypoints a child of the player's abstract node.
                wp_collider.shape = wp_shape
                waypoint.collision_layer = 2
                waypoint.collision_mask = 2
                waypoint.add_child(wp_collider)
                ref.anchor.add_child(waypoint)
            
                waypoint.position = click_position
                waypoint.position = GlobeHelpers.fix_height(waypoint, ref.anchor)
                
                var move_command := MoveCommand.new()
                move_command.entity = ref.active_entity
                print("BUT I SET IT AS ", move_command.entity)
                move_command.start_azimuth = ref.active_entity.azimuth
                move_command.start_polar = ref.active_entity.polar
                move_command.end_azimuth = click_azimuth
                move_command.end_polar = click_polar
                move_command.tolerance = ref.active_entity.move_tolerance #Currently 0.0, intolerant.
                move_command.waypoint = waypoint
                ref.order_move.emit(move_command)
                
    if Input.is_action_just_released("open_context"): #Could be secondary action...
        ref.state_machine.Change("context", {})
