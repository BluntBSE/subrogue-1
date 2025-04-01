extends Node
#class_name GlobalConst - managed by autoload

var planetary_radius := 100.00
var height:float = planetary_radius + 0.25
var munitions_lib:MunitionsLib = load("res://engine/entities/munitions/munitions_lib.tres")
var entity_lib:EntityLib = load("res://engine/entities/entity_lib.tres")
var time_scale:float = 1.0
enum TIME_SCALES {normal, slow, very_slow, fast, very_fast}
var current_scale_enum = TIME_SCALES.normal

var base_date:int = Time.get_unix_time_from_datetime_string("2100-01-01")
var game_msec_elapsed:int = 0
var game_adjusted_msec_elapsed:float = 0.0
var game_date = base_date
var is_paused := false

enum DEPTH {swim, crawl, surface}
enum GUIDANCE {active, passive, wire, dumb, radar, actipass }

var layer_navnode:int = 19
var layer_planet:int = 1
var layer_all_entities:int = 2
var layer_all_munitions:int =3
#Who knows = 4
var layer_player_1:int = 5
var layer_player_2:int = 6
var layer_player_3:int=7
var layer_player_4:int=8
var layer_player_5:int=9
var layer_player_6:int=10
var layer_faction_1:int = 11
var layer_faction_2:int = 12
var layer_faction_3:int = 13
var layer_faction_4:int = 14
var layer_faction_5:int = 15
var layer_faction_6:int = 16
var layer_faction_7:int = 17
var minor_factions:int = 18



enum layers {
    UNUSED, #Because cull masks, for whatever reason, are 1-indexed
    PLANET, #Render anything like nuclear warheads that everyone can see straight to the planet layer
    ALL_ENTITIES,
    ALL_MUNITIONS, #Do we want this?
    PLAYER_1,
    PLAYER_2,
    PLAYER_3,
    PLAYER_4,
    PLAYER_5,
    PLAYER_6,
    FACTION_1,
    FACTION_2,
    FACTION_3,
    FACTION_4,
    FACTION_5,
    FACTION_6,
    FACTION_7,
    MINOR_FACTIONS,
    NAVNODES,
    DEBUG,
}

#Acoustic modeling is complex, so we're cheating
#For game reasons, we've decided that a 90db sound at 90hz is audible up to 500km away.
#To a receiver with a sensitivity of 15db
#Let's say for every 1hz drop in pitch, you hit 15db from 10km out
#Such that an 80hz sound would attenuate to 15db at 600km


func attenuate_sound(volume: float, frequency: float, distance: float) -> float:
    # Returns the DB of the given sound at the given distance
    var base_volume = 90.0 #dB
    var base_frequency = 90.0 # Hz
    var base_distance = 500.0 # km
    var base_sensitivity = 15.0 # dB
    var base_attenuation_rate = -0.10 # dB per km
    var freq_diff = base_frequency - frequency
    var f_att_mod = frequency/base_frequency 
    var v_att_mod = volume/base_volume
    var attenuation_rate = base_attenuation_rate * f_att_mod * v_att_mod
    #print("New attenuation rate is ", attenuation_rate)
    
    # Calculate the total attenuation
    var total_attenuation = attenuation_rate * distance
    #print("Total attenuation was ", total_attenuation)
    
    # Calculate the final volume at the given distance
    var final_volume = volume + total_attenuation
    
   # print("final volume for ", volume, " pitch ", frequency, "dist ", distance)
    #print(final_volume)
    return final_volume


func is_layer_player(_int:int)->bool:
    if _int > layers.ALL_MUNITIONS:
        if _int < layers.FACTION_1:
            return true
    return false
"""
SCALE FACTORS:
    FAST:
    1 sec = 180 mins (time_scale: 180.0)
    NORMAL:
    1 sec = 60 min (time_scale: 60.0)
    SLOW:
    1 sec = 10 min (time_scale: 10.0)
    VERY:
    1 sec = 1 min (time_scale: 1.0)
"""

func _process(delta: float) -> void:
    if is_paused:
        return
    
    use_time_enum()
    
    # Calculate the adjusted elapsed time in seconds
    var adjusted_elapsed_sec = delta * (60 * time_scale) # 1 min per sec at time scale 1.0
    
    # Update game_msec_elapsed and game_adjusted_msec_elapsed
    game_msec_elapsed += int(delta * 1000)
    game_adjusted_msec_elapsed += adjusted_elapsed_sec * 1000
    
    # Update game_date
    game_date = base_date + int(game_adjusted_msec_elapsed / 1000)
    
    # Print the current game date for debugging purposes
    # print("Game Date: ", Time.get_datetime_string_from_unix_time(game_date))
    
func use_time_enum() -> void:
    match current_scale_enum:
        TIME_SCALES.fast:
            time_scale = 180.0
        TIME_SCALES.normal:
            time_scale = 60.0
        TIME_SCALES.slow:
            time_scale = 10.0
        TIME_SCALES.very_slow:
            time_scale = 1.0

func handle_set_time_scale(scale_enum: int) -> void:
    current_scale_enum = scale_enum
    use_time_enum()
