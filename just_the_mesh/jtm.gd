@tool
extends Node

@export var shape_path: String = "res://assets/trimesh_shape_highpoly.tres"
@export var export_path: String = "res://exported_shape_.gltf"
@export var write: bool = false

func _ready() -> void:
    pass
    
func _process(delta:float)->void:
    if write:
        export_shape_to_mesh_instance()
        write = false

func export_shape_to_gltf() -> void:
    var shape:ConcavePolygonShape3D = load(shape_path)
    if shape == null or not shape is ConcavePolygonShape3D:
        print("Failed to load shape or shape is not a ConcavePolygonShape3D.")
        return

    var faces = shape.get_faces()
    var vertices = PackedVector3Array()
    var indices = PackedInt32Array()

    for i in range(0, faces.size(), 3):
        vertices.append(faces[i])
        vertices.append(faces[i + 1])
        vertices.append(faces[i + 2])
        indices.append(i)
        indices.append(i + 1)
        indices.append(i + 2)

    var arrays = []
    arrays.resize(Mesh.ARRAY_MAX)
    arrays[Mesh.ARRAY_VERTEX] = vertices
    arrays[Mesh.ARRAY_INDEX] = indices

    var mesh = ArrayMesh.new()
    mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)

    var gltf_document = GLTFDocument.new()
    var gltf_node = GLTFNode.new()
    var gltf_state = GLTFState.new()
    var gltf_mesh = GLTFMesh.new()
    
    gltf_mesh = mesh
    
    gltf_state.set_meshes([gltf_mesh])
    print("Wheee")

    var result = gltf_document.write_to_filesystem(gltf_state, export_path)
    if result == OK:
        print("Shape exported successfully to: ", export_path)
    else:
        print("Failed to export shape. Error code: ", result)
        
func export_shape_to_mesh_instance() -> void:
    var shape:ConcavePolygonShape3D = load(shape_path)
    if shape == null or not shape is ConcavePolygonShape3D:
        print("Failed to load shape or shape is not a ConcavePolygonShape3D.")
        return

    var faces = shape.get_faces()
    var vertices = PackedVector3Array()
    var indices = PackedInt32Array()

    for i in range(0, faces.size(), 3):
        vertices.append(faces[i])
        vertices.append(faces[i + 1])
        vertices.append(faces[i + 2])
        indices.append(i)
        indices.append(i + 1)
        indices.append(i + 2)

    var arrays = []
    arrays.resize(Mesh.ARRAY_MAX)
    arrays[Mesh.ARRAY_VERTEX] = vertices
    arrays[Mesh.ARRAY_INDEX] = indices

    var mesh = ArrayMesh.new()
    mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
    # Create a new MeshInstance3D
    var mesh_instance = MeshInstance3D.new()
    mesh_instance.mesh = mesh

    # Add the MeshInstance3D to the scene tree
    add_child(mesh_instance)
    mesh_instance.owner = get_tree().edited_scene_root
    print("MeshInstance3D created and added to the scene.")
