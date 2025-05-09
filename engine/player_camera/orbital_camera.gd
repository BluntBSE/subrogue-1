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
        var dstr0:String =  "azimuth was previously " + str(azimuth)
        dh.dprint(db, self, dstr0)
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
       # dh.dprint(db,self, dstr)
        destination = value
var db:bool = false
var player:Player
var active_entity:Entity
var follow_cam:bool = false:
    set(value):
        print("Custom follow cam setter emitted signal")
        follow_cam = value
        freelook.emit(!value)
        if value == false:
            polar = GlobeHelpers.rads_from_position(position).polar
            azimuth = GlobeHelpers.rads_from_position(position).azimuth

#Self
signal camera_moved
var last_pos:Vector3

#World interaction
var hovering_over
var hovering_point
signal order_move
signal enqueue_move
signal close_context

#VISUAL INTERACTION (selection etc.)
signal release_observed
signal freelook #Tell the UI to tell the player we're freelooking or not

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
var accounted_for_freelook = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    pass
func unpack():
    anchor = get_tree().root.find_child("GamePlanet", true, false)
    player = get_parent().get_parent()
    active_entity = player.entities.find_child("PlayerEntity") #May be pluralized into an array later.
    set_cull_mask_value(GlobalConst.layers.PLANET, true)
    set_cull_mask_value(player.faction.faction_layer, true)
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
        
    if Engine.is_editor_hint() and not enable_debug_movement:
        return
    if follow_cam and active_entity:
        # Follow the active entity
        var target_position = active_entity.global_position
        var target_vector = (active_entity.global_position - anchor.global_position).normalized() #anchor is 0,0,0, but for completeness...
        target_vector = target_vector * distance

        # Calculate the camera's position based on the active entity's polar coordinates
        var new_position = target_vector

        # Smoothly interpolate the camera's position to the new position
        position = position.lerp(new_position, 0.1)  # Adjust the interpolation factor (0.1) as needed
        destination = position  # Keep destination synchronized with the current position
        look_at(active_entity.position)
    else:
        # Interpolate to the destination in manual mode
        position = position.lerp(destination, 0.1)
        look_at(anchor.position)
        
    # Handle hovering and input
    hovering_over = cast_from_camera()
    var dist = anchor.position - position
    dist = dist.length()
    input_movement()

    # Emit position updates
    emit_position()

    # Handle screen shake
    if trauma:
        trauma = max(trauma - trauma_decay * delta, 0)
        shake()
        
func _input(event: InputEvent) -> void:
    pass
    
func _unhandled_input(event: InputEvent) -> void:
    if unpacked != true:
        return
    
    if !is_multiplayer_authority():
        return
    if get_viewport().gui_get_focus_owner() != null:
        if event is InputEventMouseButton and event.is_released():
            print("All focus released")   
            get_viewport().gui_release_focus()
            release_observed.emit()
     
        #event.set_as_handled
    if event is InputEventKey and event.keycode == KEY_ESCAPE:
        follow_cam = false
        print("All focus released!")
        get_viewport().gui_release_focus()
        release_observed.emit()
        
    if event is InputEventKey and event.keycode in [KEY_W, KEY_A, KEY_S, KEY_D]:
        if get_viewport().gui_get_focus_owner() != null:
            return
        if follow_cam == true:
            follow_cam = false
        
    if event is InputEventKey and event.keycode == KEY_SPACE:
        if get_viewport().gui_get_focus_owner() != null:
            return
        follow_cam = true
        
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
    #Raycast from the orbital camera and collide with the planet or floating GUI elements (layer 1)
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


func move_in_orbit() -> Vector3:
    # Calculate the camera's position in spherical coordinates relative to the anchor
    var x_new = anchor.position.x + (distance * cos(azimuth) * cos(polar))
    var y_new = anchor.position.y + (distance * sin(polar))
    var z_new = anchor.position.z + (distance * sin(azimuth) * cos(polar))

    # Return the new position as a Vector3
    return Vector3(x_new, y_new, z_new)
    
    
func input_movement():
    #Set the polar coords ot the current position.Done to handle freelook

    if !get_viewport().gui_get_focus_owner() == null:
        return
    var moved:bool = false
    var zoomed:bool = false
    if Input.is_key_label_pressed(KEY_W):
        polar += move_speed
        moved = true
    if Input.is_key_label_pressed(KEY_A):
        azimuth += move_speed
        moved = true
    if Input.is_key_label_pressed(KEY_S):
        polar -= move_speed
        moved = true
    if Input.is_key_label_pressed(KEY_D):
        azimuth -= move_speed
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
    polar = GlobeHelpers.rads_from_position(position).polar
    azimuth = GlobeHelpers.rads_from_position(position).azimuth
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

func select_entity(_entity:Entity):
    #Selectable units are only selectable if they exist in the sigmap, so...
    var in_sig_map = false
    var player_entity:Entity = player.entities.find_child("PlayerEntity",true,false)
    if player_entity.detector.sigmap.get(_entity) != null:
        var sig:SignalPopup = player_entity.detector.sigmap.get(_entity)
        print("Entity existed in the sigmap. Is it positive id though?")
        if (sig.positively_identified == true) and _entity.query_any_on_layer(_entity, player.faction_layer):
            print("Attempting to select ", _entity.name)
            _entity.render.select(self)


 
func match_polar_coordinates(entity:Entity):
    
    pass
