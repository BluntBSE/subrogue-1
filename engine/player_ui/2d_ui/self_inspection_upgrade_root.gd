extends Control
class_name SelfInspectionUpgradeRoot

var last_rendered_upgrade:SelfInspectUpgradeLabel #We don't want to remove highlights on mouse_exited, only on a new hover.
#To do this, we have to remember the last rendered upgrade

# Add a member variable to track active line animations
var _active_line_tweens = {}

func _ready():
    render_upgrade()

func render_upgrade():
    #Labels contain their associated "upgrade" as part of their data.
    #update_text()
    #draw_lines_to_joint()
    #Should probably just be a linedata argument inside it.
    draw_growing_line(Vector2(0.0,0.0), Vector2(400.0,400.0), Color("ffffff"), 30.0)
    pass

class LineData:
    var point_a: Vector2
    var point_b: Vector2
    var color: Color
    var progress: float

# Need to add this to update the drawing each frame
func _process(_delta):
    queue_redraw()  # Request redraw every frame while animations are running

func draw_growing_line(point_a:Vector2, point_b:Vector2, color:Color, time_to_draw:float):
    # Generate a unique ID for this line animation
    var line_id = str(point_a) + str(point_b)
    
    # Cancel any existing tween for this line
    if line_id in _active_line_tweens and _active_line_tweens[line_id] != null:
        _active_line_tweens[line_id].kill()
    
    # Create a LineData object to store the line parameters
    var line_data = LineData.new()
    line_data.point_a = point_a
    line_data.point_b = point_b
    line_data.color = color
    line_data.progress = 0.0
    
    # Create a new tween
    var tween = create_tween()
    tween.set_ease(Tween.EASE_IN)
    tween.set_trans(Tween.TRANS_LINEAR)
    
    # Animate the progress from 0 to 1
    tween.tween_property(line_data, "progress", 1.0, time_to_draw)
    
    # Store the tween and line data
    _active_line_tweens[line_id] = tween
    
    # Connect to tween completion to cleanup
    tween.connect("finished", func(): _active_line_tweens.erase(line_id))
    
    # Store the line data in the tween's user data
    tween.set_meta("line_data", line_data)
    
    return tween  # Return the tween in case caller wants to chain animations

# Override _draw to handle the actual rendering
func _draw():
    # Draw all active lines based on their current progress
    for tween in _active_line_tweens.values():
        if tween and tween.is_valid() and tween.has_meta("line_data"):
            var data = tween.get_meta("line_data") as LineData
            var current_end = data.point_a.lerp(data.point_b, data.progress)
            draw_line(data.point_a, current_end, data.color, 2.0)
