@tool
extends Node
@export var draw_on:Area3D
@export var drawing:bool = false
@export var raycasting:bool = true
@export var debug:bool = false
@export var clear_vertices = false
var hovering_over:Dictionary = {}

#Mesh in progress
var arrays = []
var debug_spheres = []
var indices := PackedInt32Array()
var vertices := PackedVector3Array()
var normals := PackedVector3Array()

signal add_vertex_at




# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    add_vertex_at.connect(handle_add_vertex_at)
    InputMap.load_from_project_settings()
    InputMap.get_actions()
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    hovering_over = cast_from_camera()
    if hovering_over != {}:
        var dstr = str(hovering_over)
        dh.dprint(debug, dstr)
        
    input_clicks()
    pass


func cast_from_camera()->Dictionary:
    var camera = EditorInterface.get_editor_viewport_3d(0).get_camera_3d()
    if not camera:
        return {}
    #Raycast from the orbital camera and
    var space_state := camera.get_world_3d().direct_space_state
    var mouse_position = EditorInterface.get_editor_viewport_3d(0).get_mouse_position()
    var raycast_origin = camera.project_ray_origin(mouse_position)
    var raycast_end = raycast_origin + camera.project_ray_normal(mouse_position) * 8000 #normalized vectors need to be lengthened. 
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


func input_clicks():
    #BECAUSE we're not shift clicking or doing waypoint logic right now, this always overwrites the most recent item in the queue.
    if Input.is_action_just_pressed("editor_apply_to"):
        print("Foo!")
        if hovering_over != {}:
            if hovering_over.collider.name == draw_on.name:
                print("Clicked on collider", hovering_over)
                var click_position = hovering_over.position
                var click_normal = hovering_over.normal
                var click_azimuth = GlobeHelpers.rads_from_position(click_position).azimuth
                var click_polar = GlobeHelpers.rads_from_position(click_position).polar
                add_vertex_at.emit(click_position)
    if Input.is_action_just_pressed("editor_log"):
        print("Vertices are ", vertices)
        print("Indices are ", indices)
        print("Spheres are", debug_spheres)
        pass
    if Input.is_action_just_pressed("editor_clear"):
        print("Clearing all data from mesh in progress")
        vertices = PackedVector3Array()
        indices = PackedInt32Array()
        for sphere in debug_spheres:
            sphere.queue_free()
        debug_spheres = []

func handle_add_vertex_at(position: Vector3) -> void:
    print("Hello from handle_add_vertex_at")
    vertices.append(position)
    if vertices.size() % 3 == 0:
        var i = vertices.size() - 3
        indices.append(i)
        indices.append(i + 1)
        indices.append(i + 2)
        generate_mesh_from_vertices(vertices)
    
    #DEBUG SPHERES
    var mesh := SphereMesh.new()
    var sphere := MeshInstance3D.new()
    var radius = 0.5
    var height = 1.0
    mesh.radius = radius
    mesh.height = height
    sphere.mesh = mesh
    sphere.position = position #Equivalent to transform.origin
    add_child(sphere)
    debug_spheres.append(sphere)
    

func generate_mesh_from_vertices(vertices:PackedVector3Array):
    pass

"""
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
    
"""
