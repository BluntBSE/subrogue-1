extends Node3D
class_name EntityRender
#@onready depth_mesh:MeshInstance3D = %DepthMesh

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass
    

func update_depth_sprite(depth:int):
    # GlobalConst.DEPTH  enum DEPTH {swim, crawl, surface}
    var swim_sprite:Texture2D = load("res://assets/UI/white_circle_2.png")
    var crawl_sprite:Texture2D = load("res://assets/UI/white_icons/white_square_filled.png")
    var surface_sprite:Texture2D = load("res://assets/UI/white_icons/white_triangle.png")
    var depth_mesh:MeshInstance3D = %DepthMesh
    if depth == 0:
        depth_mesh.material_override.albedo_texture = swim_sprite
    if depth == 1:
        depth_mesh.material_override.albedo_texture = crawl_sprite
    if depth == 2:
        depth_mesh.material_override.albedo_texture = surface_sprite
