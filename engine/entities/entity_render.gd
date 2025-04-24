extends Node3D
class_name EntityRender
var default_color:Color
@onready var depth_mesh:MeshInstance3D = %DepthMesh
@onready var sonar_mesh:MeshInstance3D = %SonarPulseMesh
@onready var entity:Entity = get_parent()
var scaling = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    scale_with_camera_distance()
    #scale_with_fov()
    if scaling == false:
        scale = Vector3(1.0,1.0,1.0)
    else:
        scale_with_fov()
    pass
    

func update_mesh_visibilities(layer:int, val:bool):
    print(get_parent().name, "Updated mesh visibilities to ", layer, val)
    depth_mesh.set_layer_mask_value(layer, val)
    sonar_mesh.set_layer_mask_value(layer,val)
    for child in get_children():
        child.set_layer_mask_value(layer,val)
    pass
    


func recursively_modulate_all(node:Node3D, _color:Color):
    #Uniformly sets modulation, albedo, and light color where available.
    for child in get_children():
        if child.get("modulate") != null:
            child.modulate = _color
        
        recursively_modulate_all(child, _color)


func update_depth_sprite(depth:int):
    # GlobalConst.DEPTH  enum DEPTH {swim, crawl, surface}
    var swim_sprite:Texture2D = load("res://assets/UI/white_circle_2.png")
    var crawl_sprite:Texture2D = load("res://assets/UI/white_icons/white_square_filled.png")
    var surface_sprite:Texture2D = load("res://assets/UI/white_icons/white_triangle.png")
    depth_mesh = %DepthMesh
    if depth == 0:
        depth_mesh.material_override.albedo_texture = swim_sprite
    if depth == 1:
        depth_mesh.material_override.albedo_texture = crawl_sprite
    if depth == 2:
        depth_mesh.material_override.albedo_texture = surface_sprite

func update_colors(color:Color):
    default_color = color
    %DepthMesh.material_override.albedo_color = color
    %Spotlight.light_color = color
    %HeadingSprite.modulate = color

func _on_entity_mouse_entered() -> void:
    scaling = true
    #modulate = Color("ffffff")
    %Spotlight.light_color = Color("ffffff")
    %HighlightMesh.visible = true
    pass # Replace with function body.

func _on_entity_mouse_exited() -> void:
    scaling = false
    #modulate = Color("ffffff")
    %Spotlight.light_color = default_color
    %HighlightMesh.visible = false

    pass # Replace with function body.

func scale_with_camera_distance():
    #Base parameters: at 200 distance, scale of 1.0.
    #At 1000 distance, scale of 3.0
    var camera = get_viewport().get_camera_3d()
    var distance = camera.global_position - global_position
    var ratio = inverse_lerp(30, 300, distance.length())
    var sf = lerp(1.0,3.0, ratio)
    sf = clamp(sf, 0.2,2.7)
    scale = Vector3(sf,sf,sf)

func scale_with_fov():
    # Get the camera and its FOV
    var camera = get_viewport().get_camera_3d()
    if camera == null:
        return

    var fov = deg_to_rad(camera.fov)  # Convert FOV to radians
    var distance = (camera.global_position - global_position).length()

    # Calculate the scale factor to maintain a constant size
    # The apparent size is proportional to the tangent of half the FOV
    var desired_size = 1.0  # The desired size of the entity in world units
    var sf = 2.0 * distance * tan(fov / 2.0) * desired_size

    # Clamp the scale factor to avoid extreme values
    sf = clamp(sf, 0.2, 3.0)
    scale = Vector3(sf, sf, sf)
