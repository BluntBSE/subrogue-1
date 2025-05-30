extends Node3D
class_name SignalPopup

# --- SIGNAL DATA ---
var positively_identified: bool = false
var signal_id
var color: Color = Color("ffffff"):
    set(value):
        color = value
        stream_color.emit(value)
        find_child("FactionModulator", true, false).modulate = color
var faction
var detecting_object: Entity
var display_name: String
var detected_object: Entity
var certainty: float = 50.0:
    set(value):
        certainty = value
        update_threshold = calculate_update_threshold()
var hidden: bool
var sound: Sound
var lerping = false

var unpacked: bool = false
var belongs_to_npc: bool = false

# --- 3D/UI ---
var hover_scaling = false
var is_mouse_inside = false
var last_event_pos2D = null
var last_event_time: float = -1.0

@export var node_viewport: SubViewport
@export var node_quad: MeshInstance3D
@export var node_area: Area3D

var anchor: Node3D
var target_position: Vector3
var hover_height := 2.0

var needs_update: bool = false
var update_threshold: float
var last_detector_position: Vector3
var last_detected_position: Vector3
var offset: Vector3

var last_sampled_position: Vector3
var last_sampled_time: float = 0.0
var sampled_velocity: Vector3 = Vector3.ZERO

var player: Node3D
var every_x_frames = 12.0
var tweening: bool = false

signal unidentified_opened
signal identified
signal identified_opened
signal closed
signal stream
signal stream_color

func disable():
    %Area3D.input_ray_pickable = false
    visible = false
    set_process(false)

func unpack(_detecting_object: Entity, _detected_object: Entity, _sound, _certainty):
    if not _detecting_object.is_player:
        belongs_to_npc = true
        visible = false
        %MeshInstance3D.visible = false
        %Area3D.collision_layer = 0
    else:
        %Area3D.input_ray_pickable = true

    detecting_object = _detecting_object
    detected_object = _detected_object

    anchor = detecting_object.anchor
    sound = _sound
    offset = calculate_offset()
    position = detected_object.position + offset
    target_position = detected_object.position + offset  
    
    if not unpacked:
        if detecting_object.is_player:
            var id_label = find_child("SignalID", true, false)
            signal_id = SignalHelpers.generate_default_signal_id()
            id_label.text = signal_id
            player = detecting_object.played_by
            unidentified_opened.connect(player.UI.inspection_root.handle_opened_signal)
            identified_opened.connect(player.UI.inspection_root.handle_openened_identified_signal)
            identified.connect(player.UI.inspection_root.handle_identified_signal)
            stream_color.connect(player.UI.inspection_root.handle_color_stream)
        detected_object.died.connect(handle_detected_object_died)
        detecting_object.died.connect(handle_detecting_object_died)
        
    update_threshold = calculate_update_threshold()
    GlobeHelpers.recursively_update_visibility(self, 1, false)
    GlobeHelpers.recursively_update_visibility(self, detecting_object.faction.faction_layer, true)
    set_process(true)
    needs_update = true
    unpacked = true
    visible = true
    modulate_by_certainty()


func _ready():
    visible = false
    node_area.mouse_entered.connect(_mouse_entered_area)
    node_area.mouse_exited.connect(_mouse_exited_area)
    node_area.input_event.connect(_mouse_input_event)
    set_process(false)

func calculate_offset() -> Vector3:
    if not anchor or not detected_object:
        return Vector3.ZERO
    var km_offset = lerp(400.0, 0.0, certainty / 100.0)
    var position_on_sphere = detected_object.global_position.normalized()
    var random_vector = Vector3(randf(), randf(), randf()).normalized()
    var tangential_direction = random_vector.cross(position_on_sphere).normalized()
    var offset_distance = GlobeHelpers.km_to_arc_distance(km_offset, anchor)
    tweening = true
    return tangential_direction * offset_distance

func tween_to_new():
    if detected_object and tweening:
        var tween = get_tree().create_tween()
        tween.set_parallel(true)
        tween.tween_property(self, "position", target_position, 1.0)
        await tween.finished
        offset = position - detected_object.global_position
        tweening = false

func match_detected_velocity():
    if detected_object and not tweening:
        global_position = detected_object.global_position + offset

var throttle_accum: float
func _process(_delta):
    rotate_area_to_anchor()
    tween_to_new()
    match_detected_velocity()
    if hover_scaling:
        scale_with_fov()
    else:
        scale_with_camera_distance()
    check_update_necessary()
    throttle_accum += 1.0
    if throttle_accum >= every_x_frames:
        throttle_accum = 0.0
        update_if_needed()

func _mouse_entered_area():
    is_mouse_inside = true

func _mouse_exited_area():
    is_mouse_inside = false

func _unhandled_input(event):
    for mouse_event in [InputEventMouseButton, InputEventMouseMotion, InputEventScreenDrag, InputEventScreenTouch]:
        if is_instance_of(event, mouse_event):
            return
    node_viewport.push_input(event)

func _mouse_input_event(_camera: Camera3D, event: InputEvent, event_position: Vector3, _normal: Vector3, _shape_idx: int):
    var quad_mesh_size = node_quad.mesh.size
    var event_pos3D = node_quad.global_transform.affine_inverse() * event_position
    var event_pos2D = Vector2()
    if is_mouse_inside:
        event_pos2D = Vector2(event_pos3D.x, -event_pos3D.y)
        event_pos2D.x = event_pos2D.x / quad_mesh_size.x + 0.5
        event_pos2D.y = event_pos2D.y / quad_mesh_size.y + 0.5
        event_pos2D.x *= node_viewport.size.x
        event_pos2D.y *= node_viewport.size.y
    elif last_event_pos2D != null:
        event_pos2D = last_event_pos2D
    event.position = event_pos2D
    if event is InputEventMouse:
        event.global_position = event_pos2D
    if event is InputEventMouseMotion or event is InputEventScreenDrag:
        if last_event_pos2D == null:
            event.relative = Vector2(0, 0)
        else:
            event.relative = event_pos2D - last_event_pos2D
            event.velocity = event.relative / (Time.get_ticks_msec() / 1000.0 - last_event_time)
    last_event_pos2D = event_pos2D
    last_event_time = Time.get_ticks_msec() / 1000.0
    node_viewport.push_input(event)

func rotate_area_to_anchor():
    var camera = get_viewport().get_camera_3d()
    var camera_up = camera.global_transform.basis.y
    node_quad.look_at(anchor.global_transform.origin, camera_up, false)
    rotation.y = 90.0

func scale_with_camera_distance():
    var camera = get_viewport().get_camera_3d()
    var distance = camera.global_position - global_position
    var ratio = inverse_lerp(30, 300, distance.length())
    var sf = clamp(lerp(0.2, 1.8, ratio), 0.2, 2.5)
    scale = Vector3(sf, sf, sf)

func calculate_update_threshold() -> float:
    var factor = inverse_lerp(10.0, 100.0, certainty)
    return lerp(200.0, 25.0, factor)

var detecting_last_position
var detected_last_position
var diff_total_km
func check_update_necessary():
    if detected_object == null or detecting_object == null:
        return
    if detecting_last_position == null:
        detecting_last_position = detecting_object.global_position
        detected_last_position = detected_object.global_position
    if detecting_last_position and detected_last_position:
        var detected_diff = GlobeHelpers.arc_to_km(detected_object.global_position, detected_last_position, anchor)
        var detecting_diff = GlobeHelpers.arc_to_km(detecting_object.global_position, detecting_last_position, anchor)
        diff_total_km = abs(detected_diff) + abs(detecting_diff)
        if diff_total_km > update_threshold:
            needs_update = true
            detecting_last_position = detecting_object.global_position
            detected_last_position = detected_object.global_position

var last_update_time: float = 0.0
var update_interval: float = 0.5

func update_if_needed():
    var current_time = Time.get_ticks_msec() * 1000
    if needs_update and (current_time - last_update_time >= update_interval) and detected_object and detecting_object:
        last_detected_position = detected_object.global_position
        last_detector_position = detecting_object.global_position
        update_threshold = calculate_update_threshold()
        offset = calculate_offset()
        needs_update = false
        tweening = true
        target_position = detected_object.position + offset
        last_update_time = current_time
        modulate_by_certainty()
        stream.emit({"volume": sound.volume, "pitch": sound.pitch, "certainty": certainty, "entity": detected_object})

func handle_detected_object_died(_entity: Entity):
    queue_free()

func handle_detecting_object_died(_entity: Entity):
    queue_free()

func modulate_by_certainty():
    var control: Control = %SignalControlScene
    var uncertain_color = Color("262626")
    var certain_color = Color("ffffff")
    var factor = inverse_lerp(10.0, 100.0, certainty)
    control.modulate = lerp(uncertain_color, certain_color, factor)

func _on_area_3d_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
    if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_released():
        if not positively_identified:
            unidentified_opened.emit(self)
        else:
            identified_opened.emit(self)

func _on_area_3d_mouse_entered() -> void:
    %SignalControlScene.modulate = Color("00aea8")
    hover_scaling = true

func _on_area_3d_mouse_exited() -> void:
    modulate_by_certainty()
    hover_scaling = false

func handle_update_name(str: String):
    signal_id = str
    var id_label: RichTextLabel = find_child("SignalID", true, false)
    id_label.text = signal_id

func handle_update_color(_color: Color):
    %SignalControlScene.get_node("AssignedColorModulator").modulate = _color
    color = _color

func positively_identify():
    if not positively_identified:
        positively_identified = true
        color = detected_object.faction.faction_color
        stream_color.emit(color)
        var id_label: RichTextLabel = find_child("SignalID", true, false)
        var class_label: RichTextLabel = find_child("SignalClass", true, false)
        id_label.text = detected_object.given_name
        class_label.text = detected_object.atts.class_display_name
        identified.emit(self)
        position = detected_object.position
        if detecting_object.is_player and detected_object.get_multiplayer_authority() == get_multiplayer_authority() and not (detecting_object is Munition):
            SoundManager.play("ping_contact_1", "randpitch_small", "game", -3.0)

func scale_with_fov():
    var camera = get_viewport().get_camera_3d()
    if camera == null:
        return
    var fov = deg_to_rad(camera.fov)
    var distance = (camera.global_position - global_position).length()
    var desired_size = 1.0
    var sf = 2.0 * distance * tan(fov / 2.0) * desired_size
    sf = clamp(sf, 0.2, 1.5)
    scale = Vector3(sf, sf, sf)
