extends Control
class_name SelfInspectionUpgradeRoot

var last_rendered_upgrade:SelfInspectUpgradeLabel
var drawing_lines = true
var left_offset = 4.0
var down_offset = 4.0
var _active_line_tweens = {}
var active_tween_count = 0
var _completed_lines = {}  # Store completed line data
var slots = []

func _ready():
    slots.append(%SlotRear)
    slots.append(%SlotTower)
    slots.append(%SlotFront)
    render_upgrade()

func render_upgrade():
    pass

class LineData:
    var point_a: Vector2
    var point_b: Vector2
    var color: Color
    var progress: float
    var completed: bool = false  # Flag to mark if animation is complete

func _process(_delta):
    if active_tween_count > 0 or _completed_lines.size() > 0:
        queue_redraw()  # Always redraw if we have lines to show

func draw_growing_line(point_a:Vector2, point_b:Vector2, color:Color, time_to_draw:float):
    var line_id = str(point_a) + str(point_b)
    
    if line_id in _active_line_tweens and _active_line_tweens[line_id] != null:
        _active_line_tweens[line_id].kill()
        active_tween_count -= 1 
    
    # Also remove from completed lines if it exists there
    _completed_lines.erase(line_id)
    
    var line_data = LineData.new()
    line_data.point_a = point_a
    line_data.point_b = point_b
    line_data.color = color
    line_data.progress = 0.0
    
    var tween = create_tween()
    tween.set_ease(Tween.EASE_OUT)  # Changed to LINEAR for smoother animation
    tween.set_trans(Tween.TRANS_LINEAR)
    
    tween.tween_property(line_data, "progress", 1.0, time_to_draw)
    active_tween_count += 1
    
    _active_line_tweens[line_id] = tween
    
    # When tween finishes, move the line data to completed_lines
    tween.connect("finished", func(): 
        # Only process if this line is still tracked (wasn't cleared by erase_lines)
        if line_id in _active_line_tweens:
            var data = _active_line_tweens[line_id].get_meta("line_data") as LineData
            data.completed = true
            data.progress = 1.0  # Force progress to 1.0 to ensure full length
            
            # Store in completed lines
            _completed_lines[line_id] = data
            
            # Now remove from active tweens
            _active_line_tweens.erase(line_id)
            active_tween_count -= 1
    )
    
    tween.set_meta("line_data", line_data)
    
    return tween

func _draw():
    # Draw active animating lines
    for tween in _active_line_tweens.values():
        if tween and tween.is_valid() and tween.has_meta("line_data"):
            var data = tween.get_meta("line_data") as LineData
            var current_end = data.point_a.lerp(data.point_b, data.progress)
            draw_line(data.point_a, current_end, data.color, 2.0)
    
    # Draw completed lines (full length)
    for data in _completed_lines.values():
        draw_line(data.point_a, data.point_b, data.color, 2.0)
    
    # Debug: Draw joint position
    #if %LineJoint1:
       # var joint_local_pos = make_canvas_position_local(%LineJoint1.global_position)
        #draw_circle(joint_local_pos, 2.0, Color.RED)

func erase_lines():
    # Clear both active and completed lines
    for tween in _active_line_tweens.values():
        if tween and tween.is_valid():
            tween.kill()
    
    _active_line_tweens.clear()
    _completed_lines.clear()
    active_tween_count = 0
    #Reset slot circles
    for slot in slots:
        var circle:TextureRect = slot.get_node("Circle")
        circle.set_instance_shader_parameter("end_angle", 0.01)

func handle_hovered_upgrade(label:SelfInspectUpgradeLabel):
    print("Hovered over upgrade: ", label.name)
    drawing_lines = true
    
    if label != last_rendered_upgrade:
        if last_rendered_upgrade:
            last_rendered_upgrade.modulate = Color("ffffff")
        erase_lines()  # This now clears both active and completed lines
        last_rendered_upgrade = label
    
    var target_slot
    if label.upgrade.slot == "rear":
        target_slot = %SlotRear
    if label.upgrade.slot == "front":
        target_slot = %SlotFront
    if label.upgrade.slot == "tower":
        target_slot = %SlotTower
    
             
    # Calculate joint position once
    var reference_x = make_canvas_position_local(%LineJoint1.global_position).x
    var reference_y = make_canvas_position_local(target_slot.global_position).y
    var joint_pos = Vector2(reference_x, reference_y)
    
    # First line
    var origin = make_canvas_position_local(label.global_position) - Vector2(left_offset, -down_offset)
    var tween_a = draw_growing_line(origin, joint_pos, Color("34ddec"), 0.19)
    
    # Second line
    var origin_2 = make_canvas_position_local(%DescriptionBL.global_position)
    var tween_b = draw_growing_line(origin_2, joint_pos, Color("34ddec"), 0.19)
    
    label.modulate = Color("34ddec")
    await tween_a.finished
    await tween_b.finished
    
    var destination_2 = make_canvas_position_local(target_slot.global_position)
    var tween_c = draw_growing_line(joint_pos, destination_2, Color("34ddec"), 0.19)
    slot_circle_sweep_in(target_slot)


func slot_circle_sweep_in(slot:Control):
    var circle = slot.get_node("Circle")
    var tween = get_tree().create_tween()
    tween.set_ease(Tween.EASE_IN)
    tween.set_trans(Tween.TRANS_LINEAR)
    
    # For regular materials:
    tween.tween_method(func(val): circle.set_instance_shader_parameter("end_angle", val), 0.01, 359.9, 0.19)
    
