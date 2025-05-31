extends Control
class_name MarkerPopup


var context:ContextMarker
signal pressed_launch
signal pressed_hail
signal pressed_ping

func unpack(_player:Player, _context:ContextMarker)->void:
    context = _context
    print("CONTEXT WAS ", context)

    pressed_launch.connect(_player.markers.handle_launch)
    pressed_launch.connect(_player.camera.add_trauma)
    pressed_launch.connect(_player.UI.handle_launch)
    pressed_launch.connect(_player.camera.handle_launch)

    pass

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass

func pressed_launch_button()->void:
    #For now, there is only the one originating entity.
    var active_entity:Entity = context.originating_entities[0]
    pressed_launch.connect(active_entity.munitions.launch_munition)

    var active_munition:String = active_entity.munitions.active_munition
    if !active_munition:
        print("NO VALID MUNIITION")
        return
    
    if active_entity.munitions.loaded_munitions[active_munition] < 1:
        print("ACTIVE MUNITION IS EXPENDED")
        return
        
  
    #Requires muniition, start, end.
    var args = {"munition": active_munition, "originating_entity":context.originating_entities[0], "start_position": context.originating_entities[0].position, "target_position": context.position, "trauma":0.5}
    pressed_launch.emit(args) #Should there a custom signal type?A Launchcommmand?

func munitions_remaining(id:String):
    pass
