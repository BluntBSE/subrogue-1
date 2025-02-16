extends Node2D
#Accessed as SoundManager through autoload. Else, class_name SoundManager

var num_players:int = 8 #Only play 8 sounds at once. May need to go higher.
var bus:String = "master"
var sound_lib:SoundLib
var in_use:Array = [] # Players in_use. Known for the purposes of stopping sounds.
var available:Array  = []  # The available players.
var queue:Array = []  # The queue of sounds to play.
var music_volume = -3.0 #Expressed as DB modification. category: 'music'
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
        assert(false, "No sound lib registered!")
    
    #Title theme plays by default, so let's get it.
    play_straight("title_theme", "music")
    play_straight("title_ambience", "music")


func _on_stream_finished(player:AudioStreamPlayer)->void:
    # When finished playing a stream, make the player available again.
    player.pitch_scale = 1.0
    available.append(player)



func play(sound_id:String, modulation:String = "randpitch_small", category:String="game", vol:float = 0.0)->void:
    #modulations: none, randpitch_small, randpitch_med, randpitch_lg
    #TODO: Will probably need to put things into a channel here later.
    queue.append(  {"sound_id":sound_id, "modulation":modulation, "category":category, "vol": vol}  )

func play_straight(sound_id:String, category:String="game", vol:float = 0.0)->void:
    queue.append({"sound_id":sound_id, "modulation":"none", "category":category, "vol": vol})
    
func stop_sound_by_id(sound_id:String)->void:
    print("Stop sound by ID was called with", sound_id)
    for sound:Dictionary in in_use:
        if sound["sound_id"] == sound_id:
            var player:AudioStreamPlayer = sound.player
            player.stop()
            player.finished.emit() #I think this is accurate
            



func _process(delta:float)->void:
    # Play a queued sound if any players are available.
    if not  (queue.is_empty())  and (not available.is_empty()):
        var sound_command:Dictionary = queue.pop_front()
        var sound_id:String = sound_command.sound_id
        var modulation:String = sound_command.modulation
        var category:String = sound_command.category
        var vol:float = sound_command.vol
        var vol_to_use:float
        if category == "music":
            vol_to_use = music_volume
        if category == "game":
            vol_to_use = game_volume
        if category == "ui":
            vol_to_use = ui_volume
        if modulation == "none":
            var stream:AudioStream = sound_lib.get(sound_id)
            var player:AudioStreamPlayer = available[0]
            player.stream = stream
            player.volume_db = vol_to_use
            player.volume_db += vol
            player.play()
            in_use.append({"player":available[0], "sound_id":sound_id, "category":category})
            available.pop_front()
        if modulation == "randpitch_small":
            var stream:AudioStream = sound_lib.get(sound_id)
            var player:AudioStreamPlayer = available[0]
            player.stream = stream
            player.pitch_scale = randf_range(0.9, 1.1)
            player.volume_db = vol_to_use
            player.volume_db += vol
            player.play()
            in_use.append({"player":available[0], "sound_id":sound_id, "category":category})
            available.pop_front()
