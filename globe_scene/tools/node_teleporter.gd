@tool
extends Node3D
class_name NodeTeleporter
@export var active:bool = false
@export var anchor:Planet
var teleporting:Node3D
var hovering_over:Dictionary = {}
var selected_node:Node3D
var hovered_node:Node3D
var last_hovered:Node3D

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
        

    # Connect the editor's input events to this script


func _physics_process(delta: float) -> void:
    if not Engine.is_editor_hint():
        return

    if not active:
        return

    hovering_over = cast_from_camera()
    if hovering_over != {}:
        var dstr = str(hovering_over)

    var nav_intersection = cast_from_camera_teleportable()
    if nav_intersection != {}:
        hovered_node = nav_intersection.collider
        if hovered_node != last_hovered:
            if last_hovered:
                pass
    
            last_hovered = hovered_node
    else:
        hovered_node = null
        if last_hovered:
            pass
            #last_hovered._on_mouse_exited()
        last_hovered = null

    input_clicks()



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




func cast_from_camera_teleportable() -> Dictionary:
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
    #print("Hovered node is ", hovered_node)
    if Input.is_action_just_pressed("editor_apply_to"):
        
        if hovered_node != null and selected_node == null:
            selected_node = hovered_node.get_parent()
            
            return
        
        if selected_node != null:
            selected_node.position = hovering_over.position
            selected_node.do_snap()
            selected_node = null
            hovered_node = null
            return
