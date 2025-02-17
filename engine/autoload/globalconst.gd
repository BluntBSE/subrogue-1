extends Node
#class_name GlobalConst - managed by autoload

var planetary_radius := 100.00
var height:float = planetary_radius + 0.25
var munitions_lib:MunitionsLib = load("res://engine/entities/munitions/munitions_lib.tres")
var time_scale:float = 1.0
enum TIME_SCALES {normal, slow, very_slow}
var current_scale_enum = TIME_SCALES.normal

var base_date:int = Time.get_unix_time_from_datetime_string("2100-01-01")
var game_msec_elapsed:int = 0
var game_adjusted_msec_elapsed:float = 0.0
var game_date = base_date
var is_paused := false

"""
Time scale details:
Cabo Gracias a dios to Jamaica should be about 12.5 hours if we are moving a bit faster than 60kph
This is what I've decided to assign a "Speed of 20" to.
The game manages this in 4.5 seconds. Ergo, a second of game time is equivalent to how many hours of real life time?
1 sec = ~2.78 hours.
I'm okay to round this to 3.

SCALE FACTORS:
    
    1 sec = 3 hours (time_scale: 1.0)
    1 sec = 30 mins (time_scale: .16)
    1 sec = 1 min ? (time_scale: .006)
"""

func _process(delta: float) -> void:
    use_time_enum()
    var adjusted_elapsed_sec = delta * (1080 * time_scale) #Three hours per second at 1.0 time scale

    game_msec_elapsed += int(delta * 1000) 
    
    game_adjusted_msec_elapsed += round(adjusted_elapsed_sec * 1000)
    
    game_date = base_date + int(game_adjusted_msec_elapsed)
    
    # Print the current game date for debugging purposes
    # print("Game Date: ", Time.get_datetime_string_from_unix_time(game_date))
    
func use_time_enum()->void:
    match current_scale_enum:
        TIME_SCALES.normal:
            time_scale = 1.0
        TIME_SCALES.slow:
            time_scale = 0.16
        TIME_SCALES.very_slow:
            time_scale = 0.006
    

func handle_set_time_scale(scale_enum:int)->void:
    current_scale_enum = scale_enum
    use_time_enum()
