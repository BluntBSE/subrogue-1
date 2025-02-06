@tool
extends MeshInstance3D
class_name ShaderHM1

#@onready var col_shape = $ShaderCollisionShape
@export var chunk_size = 10
@export var colshape_size_ratio = 0.1
@export var do_trimesh_generation: bool = false
@export var path = "res://assets/"
@export var heightmap: Texture2D
@export var height_ratio: float = 30.0
@export var optimize:bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    #print("Hello?")
    if do_trimesh_generation:
        print("Um?")
        generate_trimesh(path)
        #export_mesh_to_obj()
        do_trimesh_generation = false
    pass

func generate_trimesh(_path: String) -> void:
    print("Generate trimesh called")
    
    # Get the mesh data
    var arrays = mesh.surface_get_arrays(0)
    var vertices = arrays[Mesh.ARRAY_VERTEX]
    var uvs = arrays[Mesh.ARRAY_TEX_UV]
    var normals = arrays[Mesh.ARRAY_NORMAL]
    
    # Apply shader deformations to the vertices
    var image = heightmap.get_image()
    if image.is_compressed():
        image.decompress()
    
    for i in range(vertices.size()):
        var uv = uvs[i]
        var x = int(uv.x * (image.get_width() - 1))
        var y = int(uv.y * (image.get_height() - 1))
        var height = image.get_pixel(x, y).a * height_ratio
        vertices[i] += normals[i] * height
    
    
    # Create a new mesh with the deformed vertices
    var new_mesh = ArrayMesh.new()
    arrays[Mesh.ARRAY_VERTEX] = vertices
    new_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
    
    # Create the trimesh shape
    var shape = new_mesh.create_trimesh_shape()
    
    # Check if the shape was created successfully
    if shape == null:
        print("Failed to create trimesh shape.")
        return
    
    # Save the shape as a resource
    var resource_path = _path + "trimesh_shape_2.tres"
    var result = ResourceSaver.save(shape, resource_path)
    
    if result == OK:
        print("Trimesh shape saved successfully at: ", resource_path)
    else:
        print("Failed to save trimesh shape. Error code: ", result)

func optimize_vertices(_mesh):
    var tolerance = 0.5
    if _mesh == null:
        print("No mesh found.")
        return

    var arrays = mesh.surface_get_arrays(0)
    var vertices = arrays[Mesh.ARRAY_VERTEX]
    var indices = arrays[Mesh.ARRAY_INDEX]

    var merged_vertices = []
    var new_indices = []
    var vertex_map = {}

    for i in range(vertices.size()):
        var vertex = vertices[i]
        var found = false

        for j in range(merged_vertices.size()):
            if merged_vertices[j].distance_squared_to(vertex) < tolerance:
                new_indices.append(j)
                found = true
                break

        if not found:
            merged_vertices.append(vertex)
            new_indices.append(merged_vertices.size() - 1)

    var new_vertices = PackedVector3Array()
    for vertex in merged_vertices:
        new_vertices.append(vertex)

    var new_indices_array = PackedInt32Array()
    for index in new_indices:
        new_indices_array.append(index)

    var new_mesh = ArrayMesh.new()
    arrays[Mesh.ARRAY_VERTEX] = new_vertices
    arrays[Mesh.ARRAY_INDEX] = new_indices_array
    new_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)

    
    print("Vertex welding complete. Reduced from ", vertices.size(), " to ", new_vertices.size(), " vertices.")
    return new_mesh


func export_mesh_to_obj() -> void:
    print("Called export mesh to objet")
    var export_path = "res://assets/test.obj"
    var mesh = self.mesh
    if mesh == null:
        print("No mesh found.")
        return

    var file = FileAccess.open(export_path, FileAccess.WRITE)
    if file == null:
        print("Failed to open file for writing.")
        return

    var arrays = mesh.surface_get_arrays(0)
    var vertices = arrays[Mesh.ARRAY_VERTEX]
    var normals = arrays[Mesh.ARRAY_NORMAL]
    var indices = arrays[Mesh.ARRAY_INDEX]

    # Write vertices
    for vertex in vertices:
        file.store_line("v %f %f %f" % [vertex.x, vertex.y, vertex.z])

    # Write normals
    for normal in normals:
        file.store_line("vn %f %f %f" % [normal.x, normal.y, normal.z])

    # Write faces
    for i in range(0, indices.size(), 3):
        var v1 = indices[i] + 1
        var v2 = indices[i + 1] + 1
        var v3 = indices[i + 2] + 1
        file.store_line("f %d//%d %d//%d %d//%d" % [v1, v1, v2, v2, v3, v3])

    file.close()
    print("Mesh exported successfully to: ", export_path)
