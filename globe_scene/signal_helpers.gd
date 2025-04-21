extends Node
class_name SignalHelpers



static var signal_prefixes = ["Roma", "Calypso", "Bravo", "Alpha", "Gemini", "Foxtrot", "Delta", "Mu", "Echo", "Hyperion", "Indigo", "Juliet", "Kilo", "Lima", "Sierra", "November", "Oleander", "Queen", "Tango", "Uniform", "Virgo"]

static func generate_default_signal_id()->String:
    var rand_idx = randi_range(0, signal_prefixes.size()-1)
    var rand_prefix = signal_prefixes[rand_idx]
    var rand_num = randi() % 99 + 10 #10 thru 99
    var output = rand_prefix + "-" + str(rand_num)
    return output
    

static func prevent_name_collision():
    pass

static func get_uncertain_size(_size:float, certainty:float):
    # Generate a random value of either -1 or 1
    var rand = randf()
    var plus_or_minus:float
    if randf() < 0.5:
        plus_or_minus = -1.0
    else:
        plus_or_minus = 1.0
    
    #0 to 80 percent certain = possible shifting of +/- .8 at the most etreme
    var uncertainty_factor = randf_range(0.0, certainty)/100.0
    var output = (uncertainty_factor * plus_or_minus) + _size
    return output
    
        
