extends Control
class_name MarkerPopup

var context:ContextMarker
signal pressed_launch
signal pressed_hail
signal pressed_ping

func unpack(_player:Player, _context:ContextMarker)->void:
    pressed_launch.connect(_player.markers.handle_launch)
    pressed_launch.connect(_player.camera.add_trauma.bind(0.5))
    pressed_launch.connect(_player.UI.handle_launch)
    pass

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass

func pressed_launch_button()->void:
    pressed_launch.emit() #Should there a custom signal type?A Launchcommmand?
    SoundManager.play("launch_thump_1", "randpitch_small", "game", 6.0)
