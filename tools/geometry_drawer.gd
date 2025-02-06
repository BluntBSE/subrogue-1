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
var extrude_up = 3.0
var extrude_down = 7.0

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
        generate_mesh_from_vertices(vertices)
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

#REWIND POINT
func handle_add_vertex_at(position: Vector3) -> void:
    print("Hello from handle_add_vertex_at")
    var direction_from_anchor = normal_from_vertex(position, draw_on)
    var new_position = position + (direction_from_anchor * extrude_up)
    
    
    vertices.append(new_position)
    
    #DEBUG SPHERES
    var mesh := SphereMesh.new()
    var sphere := MeshInstance3D.new()
    var radius = 0.5
    var height = 1.0
    mesh.radius = radius
    mesh.height = height
    sphere.mesh = mesh
    var sphere_2 = sphere.duplicate()
   # var sphere_3 = sphere.duplicate()
    sphere.position = new_position # Equivalent to transform.origin
    sphere_2.position = position
    #sphere_3.position = 
    add_child(sphere)
    add_child(sphere_2)
    debug_spheres.append(sphere)
    debug_spheres.append(sphere_2)
    
    


func generate_mesh_from_vertices(_vertices: PackedVector3Array):
    var surface_tool := SurfaceTool.new()
    surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
    
    # Every vertex in _vertices represents the high point of the plane we want to generate
    var vertices_upper = _vertices.duplicate()
    vertices_upper.reverse() # Start at the last point drawn, not the first.
    var vertices_lower = PackedVector3Array()
    
    # Create a mirror vertex beneath the anchor's surface
    for vertex in vertices_upper:
        var l_dir = (vertex - draw_on.position).normalized() * -1.0
        var l_dist = l_dir * extrude_down
        var lower_vertex: Vector3 = vertex + l_dist
        vertices_lower.append(lower_vertex)
    
    # 0,1,2 | 2, 1, 3 Counter-clockwise winding order.
    
    for i in range(vertices_upper.size() - 1):
        # 0, 1, 2
        print(i)
        surface_tool.add_vertex(vertices_upper[i])
        surface_tool.add_vertex(vertices_lower[i])
        surface_tool.add_vertex(vertices_upper[i + 1])
        
        surface_tool.add_vertex(vertices_lower[i])
        surface_tool.add_vertex(vertices_lower[i + 1])
        surface_tool.add_vertex(vertices_upper[i + 1])
    
    # surface_tool.generate_normals()
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
