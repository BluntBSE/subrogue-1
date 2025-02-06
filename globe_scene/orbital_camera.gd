@tool
extends Camera3D
class_name OrbitalCamera
@export var enable_debug_movement:bool = false
@export var anchor:Node3D
@export var min_distance := 105.0 
@export var distance:float = 150.0: #Defaults to 140.0m above the sphere. 
    set(value):
        distance = max(value, min_distance)
@export var move_speed := 0.01 #Radians
@export var zoom_speed := 10.0 #Units ('meters') away from sphere
@export var azimuth := 0.0: #Radians
    set(value):
        var dstr:String =  "azimuth is now " + str(value)
        dh.dprint(db, dstr)
        azimuth = value
@export var polar := 0.0: #Radians
    set(value):
        var dstr:String =  "polar is now " + str(value)
        dh.dprint(db, dstr)
        polar = value
var destination:Vector3:
    set(value):
        var dstr:String =  "destination is now" + str(value)
        dh.dprint(db, dstr)
        destination = value
var db:bool = false
@onready var active_entity:Entity = %PlayerEntity #May be pluralized into an array later.

#World interaction
var hovering_over
var hovering_point
signal order_move
signal enqueue_move


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    #destination = position #Initialize to editor position for now
    initialize_angles()
    destination = move_in_orbit()
    #position = destination
    look_at(anchor.position)
    if Engine.is_editor_hint(): print("Good morning from the editor")
    InputMap.load_from_project_settings()
    InputMap.get_actions()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    if Engine.is_editor_hint():
        if enable_debug_movement == false:
            return
    handle_input()
    position = lerp(position, destination, 0.1)
    look_at(anchor.position)
    hovering_over = cast_from_camera()
    #print(hovering_over.collider.name)
    
    
func cast_from_camera()->Dictionary:
    #Raycast from the orbital camera and
    var space_state := get_world_3d().direct_space_state
    var mouse_position = get_viewport().get_mouse_position()
    var raycast_origin = project_ray_origin(mouse_position)
    var raycast_end = raycast_origin + project_ray_normal(mouse_position) * 8000 #normalized vectors need to be lengthened. 
    var ray_params := PhysicsRayQueryParameters3D.new()
    ray_params.collide_with_areas = true
    ray_params.from = raycast_origin
    ray_params.to = raycast_end
    ray_params.collision_mask  = 1
    
    var intersection := space_state.intersect_ray(ray_params)
    
    if intersection.keys().size()>1:
        hovering_over = intersection
    else:
        hovering_over = {}
    
    return hovering_over


    
    
func _input(event:InputEvent):
    pass
            
func handle_input():
    input_movement()
    input_clicks()
    #print("Editor input")


func input_clicks():
    #BECAUSE we're not shift clicking or doing waypoint logic right now, this always overwrites the most recent item in the queue.
    if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
        if hovering_over != {}:
            if hovering_over.collider.name == "ClickableSphere":
                var click_position = hovering_over.position
                var click_normal = hovering_over.normal
                var click_azimuth = GlobeHelpers.rads_from_position(click_position).azimuth
                var click_polar = GlobeHelpers.rads_from_position(click_position).polar
                print("Click data: ", click_position)
                #Create a 3D area to check for collision with to determine if a movement is finished.
                var waypoint:Area3D = Area3D.new()
                var wp_collider := CollisionShape3D.new()
                var wp_shape := SphereShape3D.new() #default radius of 0.5. If we use tolerance, this might be what we assign it to.
                #Consider making these waypoints a child of the player's abstract node.
                wp_collider.shape = wp_shape
                waypoint.collision_layer = 2
                waypoint.collision_mask = 2
                waypoint.add_child(wp_collider)
                anchor.add_child(waypoint)
            
                waypoint.position = click_position
                waypoint.position = GlobeHelpers.fix_height(waypoint, anchor)
                
                var move_command := MoveCommand.new()
                move_command.start_azimuth = active_entity.azimuth
                move_command.start_polar = active_entity.polar
                move_command.end_azimuth = click_azimuth
                move_command.end_polar = click_polar
                move_command.tolerance = active_entity.move_tolerance #Currently 0.0, intolerant.
                move_command.waypoint = waypoint
                order_move.emit(move_command)
                pass

func input_movement():
    var moved:bool = false
    var zoomed:bool = false
    #TODO, and SOON - switch with is_action_pressed for remapping
    if Input.is_action_pressed("ui_up"):
        polar += move_speed
        moved = true
    if Input.is_action_pressed("ui_left"):
        azimuth -= move_speed
        moved = true
    if Input.is_action_pressed("ui_down"):
        polar -= move_speed
        moved = true
    if Input.is_action_pressed("ui_right"):
        azimuth += move_speed
        moved = true
    if Input.is_key_label_pressed(KEY_R):
        distance -= zoom_speed
        moved = true
        zoomed=true
    if Input.is_key_label_pressed(KEY_F):
        distance += zoom_speed
        moved=true
        zoomed=true
    if moved:
        destination = move_in_orbit()
    if zoomed:
            set_fov(distance * 0.1)

func move_in_orbit()->Vector3:

    
    #XZ is the azimuthal plane
    #XY and ZY are polar planes
    var x_new = anchor.position.x + ( distance * sin(azimuth) * cos(polar))
    var y_new = anchor.position.y + (distance * sin ( polar ) )
    var z_new = anchor.position.z + ( distance * cos (azimuth) * cos(polar) )
    var new_dest = Vector3(x_new,y_new,z_new)
    var relative_vector = new_dest - position

    
    return new_dest
    
    
"""
2D working
    #XZ is the azimuthal plane
    #XY and ZY are polar planes
    var x_new = anchor.position.x + ( distance * cos( azimuth ) )
    var z_new = anchor.position.z + ( distance * sin ( azimuth ) )
    var y_new = anchor.position.y 
    
    return Vector3(x_new, y_new, z_new)
"""

func initialize_angles() -> void:
    #x = sin(yaw) * cos(pitch)
    #y = radius * sin(pitch) 
    polar = asin(position.y/distance)
    azimuth = asin(position.x/cos(polar)) #Why does this do what I want when rads from position is different?
    #z = cos(yaw) * cos(pitch)
