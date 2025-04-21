#@tool
extends Node

@export var draw_on: Area3D
@export var drawing: bool = false
@export var raycasting: bool = true
@export var debug: bool = false
@export var clear_vertices: bool = false

var hovering_over: Dictionary = {}

# Mesh in progress
var mesh_arrays = []
var mesh_sprites = []
var debug_spheres = []
var mesh_indices := PackedInt32Array()
var mesh_vertices := PackedVector3Array()
var mesh_normals := PackedVector3Array()

@export var bake_mesh: bool = false
var extrude_up: float = 15.0
var extrude_down: float = 23.0
@export var flipped_normal: bool = true

signal add_vertex_at

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    add_vertex_at.connect(handle_add_vertex_at)
    #InputMap.load_from_project_settings()
    #InputMap.get_actions()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    if not Engine.is_editor_hint():
        return

    hovering_over = cast_from_camera()
    if hovering_over != {}:
        var debug_message = str(hovering_over)
        dh.dprint(debug, self, debug_message)

    if bake_mesh == true:
        generate_mesh_from_vertices(mesh_vertices)
        bake_mesh = false

    handle_input_clicks()

func cast_from_camera() -> Dictionary:
    var editor_camera = EditorInterface.get_editor_viewport_3d(0).get_camera_3d()
    if not editor_camera:
        return {}

    var space_state = editor_camera.get_world_3d().direct_space_state
    var mouse_position = EditorInterface.get_editor_viewport_3d(0).get_mouse_position()
    var raycast_origin = editor_camera.project_ray_origin(mouse_position)
    var raycast_end = raycast_origin + editor_camera.project_ray_normal(mouse_position) * 8000

    var ray_params = PhysicsRayQueryParameters3D.new()
    ray_params.collide_with_areas = true
    ray_params.from = raycast_origin
    ray_params.to = raycast_end
    ray_params.collision_mask = 1

    var ray_intersection = space_state.intersect_ray(ray_params)

    if ray_intersection.keys().size() > 1:
        hovering_over = ray_intersection
    else:
        hovering_over = {}

    return hovering_over

func handle_input_clicks():
    if Input.is_action_just_pressed("editor_apply_to"):
        if hovering_over != {}:
            if hovering_over.collider.name == draw_on.name:
                var click_position = hovering_over.position
                var click_normal = hovering_over.normal
                add_vertex_at.emit(click_position)

    if Input.is_action_just_pressed("editor_log"):
        print("Vertices are ", mesh_vertices)
        print("Indices are ", mesh_indices)
        print("Normals are", mesh_normals)
        print("Spheres are", debug_spheres)

    if Input.is_action_just_pressed("editor_clear"):
        clear_mesh_data()

func clear_mesh_data() -> void:
    print("Clearing all data from mesh in progress")
    mesh_vertices = PackedVector3Array()
    mesh_indices = PackedInt32Array()

    for sprite in mesh_sprites:
        sprite.queue_free()
    mesh_sprites = []

func handle_add_vertex_at(vertex_position: Vector3) -> void:
    var direction_from_anchor = normal_from_vertex(vertex_position, draw_on)
    var new_vertex_position = vertex_position + (direction_from_anchor * extrude_up)

    mesh_vertices.append(new_vertex_position)

    # Sprites
    var vertex_sprite = Sprite3D.new()
    vertex_sprite.texture = load("res://assets/UI/entity_dot.png")
    vertex_sprite.position = vertex_position
    vertex_sprite.billboard = 1
    add_child(vertex_sprite)
    mesh_sprites.append(vertex_sprite)

func generate_mesh_from_vertices(vertices_to_process: PackedVector3Array):
    var surface_tool = SurfaceTool.new()
    surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)

    var upper_vertices = vertices_to_process.duplicate()
    upper_vertices.reverse()
    var lower_vertices = PackedVector3Array()

    for vertex in upper_vertices:
        var lower_direction = (vertex - draw_on.position).normalized() * -1.0
        var lower_vertex = vertex + (lower_direction * extrude_down)
        lower_vertices.append(lower_vertex)

    for i in range(upper_vertices.size() - 1):
        surface_tool.add_vertex(upper_vertices[i])
        surface_tool.add_vertex(lower_vertices[i])
        surface_tool.add_vertex(upper_vertices[i + 1])

        surface_tool.add_vertex(lower_vertices[i])
        surface_tool.add_vertex(lower_vertices[i + 1])
        surface_tool.add_vertex(upper_vertices[i + 1])

    surface_tool.generate_normals(true)
    var generated_mesh = surface_tool.commit()
    if flipped_normal:
        generated_mesh = flip_mesh_faces(generated_mesh)

    var mesh_instance = MeshInstance3D.new()
    mesh_instance.mesh = generated_mesh
    add_child(mesh_instance)
    mesh_instance.owner = get_tree().edited_scene_root

    print("MeshInstance3D created and added to the scene.")

func relative_normal_from_triangle(a: Vector3, b: Vector3, c: Vector3, anchor: Node3D) -> Vector3:
    var triangle_centroid = (a + b + c) / 3.0
    var direction_from_anchor = (triangle_centroid - anchor.position).normalized()
    return direction_from_anchor

func normal_from_vertex(vertex: Vector3, anchor: Node3D) -> Vector3:
    var direction_from_anchor = (vertex - anchor.position).normalized()
    return direction_from_anchor

func flip_mesh_faces(mesh_to_flip: ArrayMesh) -> ArrayMesh:
    var flipped_mesh = ArrayMesh.new()

    for surface in range(mesh_to_flip.get_surface_count()):
        var surface_arrays = mesh_to_flip.surface_get_arrays(surface)

        var surface_vertices = surface_arrays[Mesh.ARRAY_VERTEX]
        var surface_indices = surface_arrays[Mesh.ARRAY_INDEX]

        var flipped_indices = PackedInt32Array()

        for i in range(0, surface_indices.size(), 3):
            flipped_indices.append(surface_indices[i])
            flipped_indices.append(surface_indices[i + 2])
            flipped_indices.append(surface_indices[i + 1])

        surface_arrays[Mesh.ARRAY_INDEX] = flipped_indices
        flipped_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, surface_arrays)

    return flipped_mesh
