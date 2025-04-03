@tool
extends Node

@export var draw_on: Area3D
@export var drawing: bool = false
@export var raycasting: bool = true
@export var debug: bool = false
@export var clear_vertices: bool = false

var hovering_over: Dictionary = {}

# Mesh in progress
var arrays = []
var sprites = []
var debug_spheres = []
var indices := PackedInt32Array()
var vertices := PackedVector3Array()
var normals := PackedVector3Array()

@export var bake_mesh: bool = false
var extrude_up: float = 15.0
var extrude_down: float = 23.0
@export var flipped_normal: bool = true

signal add_vertex_at

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    add_vertex_at.connect(handle_add_vertex_at)
    InputMap.load_from_project_settings()
    InputMap.get_actions()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    if not Engine.is_editor_hint():
        return

    hovering_over = cast_from_camera()
    if hovering_over != {}:
        var debug_string = str(hovering_over)
        dh.dprint(debug, self, debug_string)

    if bake_mesh == true:
        generate_mesh_from_vertices(vertices)
        bake_mesh = false

    handle_input_clicks()

func cast_from_camera() -> Dictionary:
    var camera = EditorInterface.get_editor_viewport_3d(0).get_camera_3d()
    if not camera:
        return {}

    var space_state = camera.get_world_3d().direct_space_state
    var mouse_position = EditorInterface.get_editor_viewport_3d(0).get_mouse_position()
    var raycast_origin = camera.project_ray_origin(mouse_position)
    var raycast_end = raycast_origin + camera.project_ray_normal(mouse_position) * 8000

    var ray_params = PhysicsRayQueryParameters3D.new()
    ray_params.collide_with_areas = true
    ray_params.from = raycast_origin
    ray_params.to = raycast_end
    ray_params.collision_mask = 1

    var intersection = space_state.intersect_ray(ray_params)

    if intersection.keys().size() > 1:
        hovering_over = intersection
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
        print("Vertices are ", vertices)
        print("Indices are ", indices)
        print("Normals are", normals)
        print("Spheres are", debug_spheres)

    if Input.is_action_just_pressed("editor_clear"):
        clear_data()

func clear_data() -> void:
    print("Clearing all data from mesh in progress")
    vertices = PackedVector3Array()
    indices = PackedInt32Array()

    for sprite in sprites:
        sprite.queue_free()
    sprites = []

func handle_add_vertex_at(vertex_position: Vector3) -> void:
    var direction_from_anchor = normal_from_vertex(vertex_position, draw_on)
    var new_position = vertex_position + (direction_from_anchor * extrude_up)

    vertices.append(new_position)

    # Sprites
    var new_sprite = Sprite3D.new()
    new_sprite.texture = load("res://assets/UI/entity_dot.png")
    new_sprite.position = vertex_position
    new_sprite.billboard = 1
    add_child(new_sprite)
    sprites.append(new_sprite)

func generate_mesh_from_vertices(mesh_vertices: PackedVector3Array):
    var surface_tool = SurfaceTool.new()
    surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)

    var vertices_upper = mesh_vertices.duplicate()
    vertices_upper.reverse()
    var vertices_lower = PackedVector3Array()

    for vertex in vertices_upper:
        var lower_direction = (vertex - draw_on.position).normalized() * -1.0
        var lower_vertex = vertex + (lower_direction * extrude_down)
        vertices_lower.append(lower_vertex)

    for i in range(vertices_upper.size() - 1):
        surface_tool.add_vertex(vertices_upper[i])
        surface_tool.add_vertex(vertices_lower[i])
        surface_tool.add_vertex(vertices_upper[i + 1])

        surface_tool.add_vertex(vertices_lower[i])
        surface_tool.add_vertex(vertices_lower[i + 1])
        surface_tool.add_vertex(vertices_upper[i + 1])

    surface_tool.generate_normals(true)
    var mesh = surface_tool.commit()
    if flipped_normal:
        mesh = flip_mesh_faces(mesh)

    var mesh_instance = MeshInstance3D.new()
    mesh_instance.mesh = mesh
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

func flip_mesh_faces(mesh: ArrayMesh) -> ArrayMesh:
    var flipped_mesh = ArrayMesh.new()

    for surface in range(mesh.get_surface_count()):
        var arrays = mesh.surface_get_arrays(surface)

        var vertices = arrays[Mesh.ARRAY_VERTEX]
        var indices = arrays[Mesh.ARRAY_INDEX]

        var flipped_indices = PackedInt32Array()

        for i in range(0, indices.size(), 3):
            flipped_indices.append(indices[i])
            flipped_indices.append(indices[i + 2])
            flipped_indices.append(indices[i + 1])

        arrays[Mesh.ARRAY_INDEX] = flipped_indices
        flipped_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)

    return flipped_mesh
