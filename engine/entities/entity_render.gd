extends Node3D
class_name EntityRender
var default_color:Color
@onready var depth_mesh:MeshInstance3D = %DepthMesh
@onready var sonar_mesh:MeshInstance3D = %SonarPulseMesh
@onready var entity:Entity = get_parent()
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
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

    #modulate = Color("ffffff")
    %Spotlight.light_color = Color("ffffff")
    %DepthMesh2.visible = true
    pass # Replace with function body.

func _on_entity_mouse_exited() -> void:
    #modulate = Color("ffffff")
    %Spotlight.light_color = default_color
    %DepthMesh2.visible = false

    pass # Replace with function body.
