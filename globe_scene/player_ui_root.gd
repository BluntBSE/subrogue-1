extends Control
const TIMER_LIMIT = 2.0
var timer = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta:float):
    timer += delta
    if timer > TIMER_LIMIT: # Prints every 2 seconds
        timer = 0.0
        %fps_printer.text = str(Engine.get_frames_per_second())
