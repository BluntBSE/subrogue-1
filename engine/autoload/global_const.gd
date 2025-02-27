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
