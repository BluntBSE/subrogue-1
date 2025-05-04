extends Node2D
#Accessed as SoundManager through autoload. Else, class_name SoundManager

var num_players:int = 32 #Only play 8 sounds at once. May need to go higher.
var bus:String = "master"
var sound_lib:SoundLib
var in_use:Array = [] # Players in_use. Known for the purposes of stopping sounds.
var available:Array  = []  # The available players.
var queue:Array = []  # The queue of sounds to play.
var music_volume = -15.0 #Expressed as DB modification. category: 'music'
var ui_volume = 0.0 #Expressed as DB modification. category: 'ui'
var game_volume = 0.0 #Expressed as DB modification. category 'game'


func _ready()->void:
    # Create the pool of AudioStreamPlayer nodes.
    for i in num_players:
        var p := AudioStreamPlayer.new()
        add_child(p)
        available.append(p)
        p.connect("finished", _on_stream_finished.bind(p))
        p.bus = bus
    sound_lib = load("res://engine/sound/sound_lib.tres")
    if sound_lib == null:
        push_error("No sound lib registered!")
    
    #Title theme plays by default, so let's get it.
    play_straight("title_theme", "music")
    play_straight("title_ambience", "music")
    
    #Dynamic bindings
    get_tree().node_added.connect(_on_node_added)


func _on_stream_finished(player:AudioStreamPlayer)->void:
    # Remove the player from in_use when finished
    for i in range(in_use.size() - 1, -1, -1):
        if in_use[i]["player"] == player:
            in_use.remove_at(i)
            break
    
    # When finished playing a stream, make the player available again.
    player.pitch_scale = 1.0
    available.append(player)



func play(sound_id:String, modulation:String = "randpitch_small", category:String="game", vol:float = 0.0)->void:
    #modulations: none, randpitch_small, randpitch_med, randpitch_lg
    #TODO: Will probably need to put things into a channel here later.
    queue.append({"sound_id":sound_id, "modulation":modulation, "category":category, "vol": vol})

func play_straight(sound_id:String, category:String="game", vol:float = 0.0)->void:
    queue.append({"sound_id":sound_id, "modulation":"none", "category":category, "vol": vol})
    
func stop_sound_by_id(sound_id:String)->void:
    for i in range(in_use.size() - 1, -1, -1):
        if in_use[i]["sound_id"] == sound_id:
            var player = in_use[i]["player"]
            player.stop()
            # No need to manually emit finished - stopping will trigger the signal naturally
            # Remove from in_use immediately to prevent race conditions
            in_use.remove_at(i)
            available.append(player)


func _process(_delta:float)->void:
    print("AVAILABLE ", available.size())
    print("IN USE ", in_use.size())
    
    # Play a queued sound if any players are available.
    if not queue.is_empty() and not available.is_empty():
        var sound_command:Dictionary = queue.pop_front()
        var sound_id:String = sound_command.sound_id
        var modulation:String = sound_command.modulation
        var category:String = sound_command.category
        var vol:float = sound_command.vol
        
        # Get base volume for the category
        var vol_to_use:float = 0.0
        match category:
            "music": vol_to_use = music_volume
            "game": vol_to_use = game_volume
            "ui": vol_to_use = ui_volume
        
        # Get the player and set it up
        var player:AudioStreamPlayer = available.pop_front()
        var stream:AudioStream = sound_lib.get(sound_id)
        player.stream = stream
        player.volume_db = vol_to_use + vol
        
        # Apply modulation if needed
        match modulation:
            "randpitch_small":
                player.pitch_scale = randf_range(0.9, 1.1)
            # Add other modulation types here if needed
        
        # Play the sound and track it
        player.play()
        in_use.append({"player": player, "sound_id": sound_id, "category": category})


##RUNTIME BINDING OF SOUNDS TO UI

##BUTTONS:
func _on_node_added(node:Node) -> void:
    if node is Button or node is TextureButton:
        # If the added node is a button we connect to its mouse_entered and pressed signals
        # and play a sound
        node.mouse_entered.connect(_play_hover)
        node.pressed.connect(_play_pressed)
        
func _play_hover():
    play_straight("button_hover", "ui", -4.0)

func _play_pressed():
    play_straight("button_press", "ui", -4.0)
