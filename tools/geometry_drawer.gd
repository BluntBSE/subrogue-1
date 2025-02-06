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
@export var bake_mesh:bool = false


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
        
    if bake_mesh == true:
        generate_mesh_from_vertices(vertices, indices, normals)
        bake_mesh = false
        
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
        print("Normals are", normals)
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
    normals.append(normal_from_vertex(position, draw_on))
    if vertices.size() % 3 == 0:
        var i = vertices.size() - 3
        indices.append(i)
        indices.append(i + 1)
        indices.append(i + 2)
    
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
    


func generate_mesh_from_vertices(_vertices: PackedVector3Array, _indices:PackedInt32Array, _normals:PackedVector3Array):
    arrays.resize(Mesh.ARRAY_MAX)
    arrays[Mesh.ARRAY_VERTEX] = _vertices
    arrays[Mesh.ARRAY_INDEX] = _indices
    arrays[Mesh.ARRAY_NORMAL] = _normals
    var surface_tool := SurfaceTool.new()
    surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
    var v_index:int = 0
    for vertex in _vertices:
        surface_tool.set_uv(Vector2(v_index/_vertices.size(),v_index/_vertices.size())) #If I have 10 vertices, I want 0 to be UV of 0, 10 to be UV of 1. Ergo: 
        surface_tool.set_color(Color("Red"))
        surface_tool.add_vertex(vertex)
    
    surface_tool.generate_normals()
    var mesh = surface_tool.commit()
    var mesh_instance = MeshInstance3D.new()
    mesh_instance.mesh = mesh
    add_child(mesh_instance)
    mesh_instance.owner = get_tree().edited_scene_root
    
    
    print("MeshInstance3D created and added to the scene.")
    

func relative_normal_from_triangle(a:Vector3, b:Vector3, c:Vector3, anchor:Node3D)->Vector3:
    var triangle_centroid  = ( a + b + c)/3.0
    var dir_from_anchor = triangle_centroid - anchor.position #Anchor is always 0.0 but still
    dir_from_anchor = dir_from_anchor.normalized()
    
    return Vector3()

func normal_from_vertex(vertex:Vector3, anchor)->Vector3:
    var dir_from_anchor:Vector3 = vertex - anchor.position
    dir_from_anchor = dir_from_anchor.normalized()
    return dir_from_anchor
