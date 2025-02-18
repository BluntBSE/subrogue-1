extends Control
class_name MarkerPopup


var context:ContextMarker
signal pressed_launch
signal pressed_hail
signal pressed_ping

func unpack(_player:Player, _context:ContextMarker)->void:
    pressed_launch.connect(_player.markers.handle_launch)
    pressed_launch.connect(_player.camera.add_trauma)
    pressed_launch.connect(_player.UI.handle_launch)
    pressed_launch.connect(_player.entities.launch_munition)
    pressed_launch.connect(_player.camera.handle_launch)
    context = _context
    pass

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass

func pressed_launch_button()->void:
    var debug_munition:Munition = MunitionHelpers.munition_by_id("manta_torpedo")
    #Requires muniition, start, end.
    #For now, there is only the one originating entity.
    var args = {"munition": debug_munition, "start_position": context.originating_entities[0].position, "target_position": context.position, "trauma":0.5}
    pressed_launch.emit(args) #Should there a custom signal type?A Launchcommmand?
    SoundManager.play("launch_thump_1", "randpitch_small", "game", 6.0)
