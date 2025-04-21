@tool
extends Node3D
@export var draw_on:Area3D
@export var raycasting:bool = true
@export var active:bool = false
@export var debug:bool = true
@export var nav_parent:Node3D #To which navnodes are parented
var hovering_over:Dictionary = {}
var nodes_prepared:Array = [] #Nodes we'e ready to put down, but not quite uet
var last_node:Node3D #Most recent ,for undo
var hovered_node:NavNode
var last_hovered:NavNode #To detect no longer looking at a given node
var selected_node:NavNode

signal add_node_at
signal add_and_link

func _enter_tree():
    print("Navnode plugin initiated")
    #GODOTMEETUP1 - Doing "load_from_project_settings" in a @tool causes all kinds of noisy errors.
    #I would take a stab at modifying this but I don't really know where to start.
    #InputMap.load_from_project_settings()
    
    #The workaround I use to avoid this as follows.
    if !InputMap.has_action("editor_apply_to"):
        InputMap.add_action("editor_apply_to")
        var mouse_event_EAT := InputEventMouseButton.new()
        mouse_event_EAT.button_index = MOUSE_BUTTON_XBUTTON2
        InputMap.action_add_event("editor_apply_to", mouse_event_EAT)
        
    if !InputMap.has_action("editor_log"):
        InputMap.add_action("editor_log")
        var mouse_event_EAT := InputEventMouseButton.new()
        mouse_event_EAT.button_index = MOUSE_BUTTON_XBUTTON1
        InputMap.action_add_event("editor_apply_to", mouse_event_EAT)
        
    if not InputMap.has_action("editor_clear"):
        InputMap.add_action("editor_clear")
        var mouse_event_EAT = InputEventMouseButton.new()
        mouse_event_EAT.button_index = MOUSE_BUTTON_XBUTTON1
        mouse_event_EAT.shift = true  # Require SHIFT to be held
        mouse_event_EAT.pressed = true  # Indicates the button is pressed
        # Add the event to the action
        InputMap.action_add_event("editor_log", mouse_event_EAT)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    add_node_at.connect(handle_add_node_at)
    #InputMap.load_from_project_settings()
    #InputMap.get_actions()
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    if not Engine.is_editor_hint():
        return

    if not active:
        return

    hovering_over = cast_from_camera()
    if hovering_over != {}:
        var dstr = str(hovering_over)

    var nav_intersection = cast_from_camera_nav()
    if nav_intersection != {}:
        hovered_node = nav_intersection.collider
        hovered_node._on_mouse_entered()
        if hovered_node != last_hovered:
            if last_hovered:
                last_hovered._on_mouse_exited()
            last_hovered = hovered_node
    else:
        hovered_node = null
        if last_hovered:
            last_hovered._on_mouse_exited()
        last_hovered = null

    input_clicks()

func handle_add_node_at(_position: Vector3) -> void:
    var navnode:NavNode = load("res://engine/navigation/nav_node.tscn").instantiate()
    nav_parent.add_child(navnode)
    var rads = GlobeHelpers.rads_from_position(_position)
    navnode.owner = get_tree().edited_scene_root
    navnode.name =  "NavNode-" + str(snapped(rad_to_deg(rads.azimuth), 0.01)) +"lon-"+str (snapped(rad_to_deg(rads.polar),0.01))+"lat"
    navnode.position = _position
    last_node = navnode
    pass

func handle_add_and_link(_position:Vector3)->void:
    var navnode:NavNode = load("res://engine/navigation/nav_node.tscn").instantiate()
    nav_parent.add_child(navnode)
    var rads = GlobeHelpers.rads_from_position(_position)
    navnode.owner = get_tree().edited_scene_root
    navnode.name =  "NavNode-" + str(snapped(rad_to_deg(rads.azimuth), 0.01)) +"lon-"+str (snapped(rad_to_deg(rads.polar),0.01))+"lat"
    navnode.position = _position
    print("Last node was", last_node.name)
    navnode.add_link(last_node)
    last_node = navnode
    pass


func cast_from_camera() -> Dictionary:
    var camera = EditorInterface.get_editor_viewport_3d(0).get_camera_3d()
    if not camera:
        return {}
    # Raycast from the orbital camera
    var space_state := camera.get_world_3d().direct_space_state
    var mouse_position = EditorInterface.get_editor_viewport_3d(0).get_mouse_position()
    var raycast_origin = camera.project_ray_origin(mouse_position)
    var raycast_end = raycast_origin + camera.project_ray_normal(mouse_position) * 8000 # normalized vectors need to be lengthened.
    var ray_params := PhysicsRayQueryParameters3D.new()
    ray_params.collide_with_areas = true
    ray_params.from = raycast_origin
    ray_params.to = raycast_end
    ray_params.collision_mask = 1

    var intersection := space_state.intersect_ray(ray_params)
    return intersection
    

func cast_from_camera_nav() -> Dictionary:
    var camera = EditorInterface.get_editor_viewport_3d(0).get_camera_3d()
    if not camera:
        return {}
    # Raycast from the orbital camera
    var space_state := camera.get_world_3d().direct_space_state
    var mouse_position = EditorInterface.get_editor_viewport_3d(0).get_mouse_position()
    var raycast_origin = camera.project_ray_origin(mouse_position)
    var raycast_end = raycast_origin + camera.project_ray_normal(mouse_position) * 8000 # normalized vectors need to be lengthened.
    var ray_params := PhysicsRayQueryParameters3D.new()
    ray_params.collide_with_areas = true
    ray_params.from = raycast_origin
    ray_params.to = raycast_end
    ray_params.collision_mask = 1 << 18 # Only collide with objects on layer 19.

    var intersection := space_state.intersect_ray(ray_params)
    return intersection




func input_clicks():
    if Input.is_action_just_pressed("editor_apply_to"):
        print("Received editor apply to")
        
        if hovered_node != null and selected_node == null:
            print("Setting selected node to ", hovered_node)
            selected_node = hovered_node
            return
        
        if hovered_node != null and selected_node != null:
            #Do linking
            print("Linking ", selected_node, " with ", hovered_node)
            selected_node.add_link(hovered_node)
            selected_node = null
            hovered_node = null
            return
        
        print("What in the world")
        print(hovering_over)
        if hovering_over != {}:
            print("Non null hover target, should be drawing")
            selected_node = null
            hovered_node = null
            print("SELECTED", selected_node)
            print("HOVERED", hovered_node)
            if Input.is_key_label_pressed(KEY_SPACE): #Auto link mode
                print("MERP")
                if hovering_over.collider.name == draw_on.name:
                    var click_position = hovering_over.position
                #var click_normal = hovering_over.normal
                    handle_add_and_link(click_position)    
                    return                
            if hovering_over.collider.name == draw_on.name:
                var click_position = hovering_over.position
                #var click_normal = hovering_over.normal
                handle_add_node_at(click_position)
                
    if Input.is_action_just_pressed("editor_log"):

        pass
    if Input.is_action_just_pressed("editor_clear"):
        clear_data()

func handle_hovered_node(node:NavNode)->void:
    hovered_node = node
    pass

func handle_exited_node(node:NavNode)->void:
    hovered_node = null
    pass
        
func clear_data()->void:
    pass
