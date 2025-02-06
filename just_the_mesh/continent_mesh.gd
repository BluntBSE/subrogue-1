@tool
extends MeshInstance3D
class_name LandMesh


@export var update:bool = false
@export var clear_debug_vis:bool = false
@export var planet_mesh:MeshInstance3D
@export var planet_texture:Texture2D

func get_mesh_data(mesh_instance: MeshInstance3D):
    var _mesh = mesh_instance.mesh
    print("Is there a mesh?", _mesh)
    var surfaces=[]
    var surface_count = _mesh.get_surface_count()

    var surface = _mesh.surface_get_arrays(0) #We only have 1 surface on the sphere, no iteration required.
    var surface_uvs = surface[Mesh.ARRAY_TEX_UV]
    var vertices = surface[Mesh.ARRAY_VERTEX]
    var tex = load("res://assets/collision_mask.png")
    #var img = get_texture_image(mesh_instance.get_active_material(0).albedo_texture)
    var img = get_texture_image(tex)
    #find_matching_uvs(mesh_instance.material_override, surface_uvs, COLOR("#d98999"))
    var muvs = find_matching_uvs(img, surface_uvs) # Color("#d98999") )
    for muv in muvs:
        if muv in surface_uvs:
            print("foo!")
    
    
    

func find_matching_uvs(img: Image, uvs: PackedVector2Array) -> Array:
    var sampling = 100
    var img_width = img.get_width()
    var img_height = img.get_height()
    var matching_uvs = []

    for x in range(0, img_width, sampling):
        for y in range(0, img_height, sampling):
            if img.get_pixel(x, y).a > 0:
                # Convert to UV
                var uv_x = float(x) / float(img_width)
                var uv_y = float(y) / float(img_height)
                var uv = Vector2(uv_x, uv_y)
                matching_uvs.append(uv)
    #print(matching_uvs)
    return matching_uvs



func get_texture_image(text:Texture2D):
    var image = text.get_image()
    if image.is_compressed():
        image.decompress()
        
   # image.lock() #I think this is fake
    return image
    

func _process(delta:float)->void:
    if update:
        call_deferred("get_mesh_data", planet_mesh)  
        update = false
    
    
