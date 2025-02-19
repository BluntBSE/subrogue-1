extends Control
class_name PlayerUIRoot

const TIMER_LIMIT = 2.0
var timer = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    pass # Replace with function body.




func adjust_ruler(camera_pos:Vector3, anchor:Vector3) -> void:
    pass
    
    

@onready var camera = %OrbitalCamera # Adjust the path to your Camera3D node
@onready var viewport = get_viewport() # Adjust the path to your Viewport node
@onready var anchor = %GamePlanet

func _process(delta: float) -> void:
    #FPS
    %FPSCounter.text = "FPS: " + str(Engine.get_frames_per_second())
    
    #RANGEFINDING
    # Get the mouse position relative to the Control node
    var ray_length = 8000.0 # Adjust the ray length as needed
    var mouse_pos = get_global_mouse_position()
    
    var ray_origin_a = camera.project_ray_origin(%RangeFinder1.position)
    var ray_direction_a = camera.project_ray_normal(%RangeFinder1.position)
    var ray_end_a = ray_origin_a + (ray_direction_a * ray_length)
    
    var ray_origin_b = camera.project_ray_origin(%RangeFinder2.position)
    var ray_direction_b = camera.project_ray_normal(%RangeFinder2.position)
    var ray_end_b = ray_origin_b + (ray_direction_b * ray_length)
    
    
    # Perform the raycast
    var space_state:PhysicsDirectSpaceState3D = camera.get_world_3d().direct_space_state

    var ray_params_a := PhysicsRayQueryParameters3D.new()
    ray_params_a.collide_with_areas = true
    ray_params_a.from = ray_origin_a
    ray_params_a.to = ray_end_a
    ray_params_a.collision_mask  = 1
    var result_a = space_state.intersect_ray(ray_params_a)
    
    var ray_params_b := PhysicsRayQueryParameters3D.new()
    ray_params_b.collide_with_areas = true
    ray_params_b.from = ray_origin_b
    ray_params_b.to = ray_end_b
    ray_params_b.collision_mask  = 1
    var result_b = space_state.intersect_ray(ray_params_b)
    
    
    
    if result_a and result_b:
        
        var km = GlobeHelpers.arc_to_km(result_a.position, result_b.position, anchor)
        km = snapped(km, 1.0)
        %RulerLabel.text = str(km) + " km"


func handle_launch(_args:Dictionary)->void:
    var glitch_mask:ColorRect = get_node("FilterMaskGlitch")
    glitch_mask.material.set("shader_parameter/active", true)
    await get_tree().create_timer(0.8).timeout
    glitch_mask.material.set("shader_parameter/active", false)
    pass
    
    
