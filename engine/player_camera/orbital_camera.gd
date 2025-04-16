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
        dh.dprint(db, self, dstr)
        azimuth = value
@export var polar := 0.0: #Radians
    set(value):
        var dstr:String =  "polar is now " + str(value)
        dh.dprint(db, self, dstr)
        polar = value
var destination:Vector3:
    set(value):
        var dstr:String =  "destination is now" + str(value)
        dh.dprint(db,self, dstr)
        destination = value
var db:bool = false
var player:Player
var active_entity:Entity

#Self
signal camera_moved
var last_pos:Vector3

#World interaction
var hovering_over
var hovering_point
signal order_move
signal enqueue_move
signal close_context

var state_machine:StateMachine

#Screen shake params
@export var trauma_decay = 0.8;
@export var max_offset = Vector2(100,75);
@export var max_roll = 0.1
var pre_trauma_position:Vector3
var return_to_pre_trauma:bool
#following the anchor, else: export var target
var trauma = 0.0
var trauma_power = 2 #2, 3. Exponent
var noise_map := FastNoiseLite.new()

var noise_y = 0
var unpacked = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    pass
func unpack():
    anchor = get_tree().root.find_child("GamePlanet", true, false)
    player = get_parent().get_parent()
    active_entity = player.entities.find_child("PlayerEntity") #May be pluralized into an array later.
    set_cull_mask_value(GlobalConst.layers.PLANET, true)
    set_cull_mask_value(player.faction, true)
    state_machine = StateMachine.new()
    state_machine.Add("navigating", CamNavState.new(self, {}))
    state_machine.Add("context", CamContextState.new(self,{}))
    #destination = position #Initialize to editor position for now
    initialize_angles()
    destination = move_in_orbit()
    #position = destination
    look_at(anchor.position)
    if Engine.is_editor_hint(): print("Good morning from the editor")
   # InputMap.load_from_project_settings()
   # InputMap.get_actions()
    state_machine.Change("navigating", {})
    last_pos = position
    #TODO: Figure out how to randomize these later.
    noise_map.noise_type = FastNoiseLite.TYPE_SIMPLEX
    noise_map.seed = randi()
    noise_map.frequency = 4
    noise_map.fractal_octaves = 2
    randomize()
    unpacked = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    if unpacked != true:
        return
    
    if !is_multiplayer_authority():
        return
        
    if Engine.is_editor_hint():
        if enable_debug_movement == false:
            return
            
    if not trauma:
        if return_to_pre_trauma:
            print("Returnt oo pre")
            #destination = pre_trauma_position
            return_to_pre_trauma = false
            
    position = lerp(position, destination, 0.1)
    look_at(anchor.position)
    hovering_over = cast_from_camera()
    #print(hovering_over.collider.name)
    var dist = anchor.position - position
    dist = dist.length()
    #%WorldEnvironment.environment.set_volumetric_fog_length(dist) #If we do multiplayer this can't be the way this works. Can each player have their own world environment node? Probably, honestly.
    input_movement() #At least until I want a state machine to change its behavior.
    emit_position()
    if trauma:
        trauma = max(trauma - trauma_decay * delta, 0)
        shake()
func _input(event:InputEvent):
    pass  
    
func _unhandled_input(event: InputEvent) -> void:
    if unpacked != true:
        return
    
    if !is_multiplayer_authority():
        return
        
    state_machine.handleInput({"event":event})
    pass
    
func drop_context_marker(point: Vector3) -> Node3D:
    var marker:ContextMarker = preload("res://engine/player_ui/3d_ui/marker_popup_3d.tscn").instantiate()
 
    marker.position = hovering_over.position
    %PlayerMarkers.add_marker(marker)

    #If hovering over an entity, unpack such that node b is the entity not the marker. For now:
    marker.unpack(player, player.entities.find_child("PlayerEntity"), marker, anchor)
    
  
    return marker
    
 
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


func move_in_orbit()->Vector3:

    
    #XZ is the azimuthal plane
    #XY and ZY are polar planes
    var x_new = anchor.position.x + ( distance * sin(azimuth) * cos(polar))
    var y_new = anchor.position.y + (distance * sin ( polar ) )
    var z_new = anchor.position.z + ( distance * cos (azimuth) * cos(polar) )
    var new_dest = Vector3(x_new,y_new,z_new)
    var relative_vector = new_dest - position

    
    return new_dest
    
    
func input_movement():
    var moved:bool = false
    var zoomed:bool = false
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
        distance -=zoom_speed
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

func initialize_angles() -> void:
    #x = sin(yaw) * cos(pitch)
    #y = radius * sin(pitch) 
    polar = asin(position.y/distance)
    azimuth = asin(position.x/cos(polar)) #Why does this do what I want when rads from position is different?
    #z = cos(yaw) * cos(pitch)

func emit_position()->void:
    var threshold = 0.5
    if (position-last_pos).length() > threshold:
            last_pos = position
            camera_moved.emit(position, anchor.position)




func add_trauma(args:Dictionary):
    print("ADD TRAUMA RECEIVED", args.trauma)
    var amount = args.trauma
    pre_trauma_position = position
    trauma = min(trauma + amount, 1.0);
    print("SET RETURN TO PRE TRAUMA TO TRUE")
    return_to_pre_trauma = true
    
func shake():
    var amount = pow(trauma, trauma_power)
    noise_y += 1
    rotation.z = max_roll * amount * randf_range(-1, 1)
    var offset:Vector2
    offset.x = max_offset.x * amount * randf_range(-1, 1)
    offset.y = max_offset.y * amount * randf_range(-1, 1)
    destination.z += offset.x
    destination.y += offset.y
    
func handle_launch(_args:Dictionary)->void:
    state_machine.Change("navigating", {})
    pass
