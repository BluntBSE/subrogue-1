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

static func get_uncertain_size(_size: float, certainty: float) -> float:
    randomize()
    # Certainty comes in as a number between 1 and 100
    # Clamp certainty to ensure it's within the valid range
    certainty = clamp(certainty, 1.0, 100.0)

    # Calculate the uncertainty factor (randomized based on certainty)
    var uncertainty_factor = randf_range(0.0, 100.0 - certainty)

    # Determine the maximum displacement as a percentage of the size
    var max_displacement = 0.25 * _size  # 25% of the size

    # Scale the displacement based on the uncertainty factor
    var displacement = lerp(0.0, max_displacement, uncertainty_factor / 100.0)

    # Randomly decide if the displacement is positive or negative
    var plus_or_minus = 1.0
    if randf_range(-1.0, 1.0) < 0.0:
        plus_or_minus = -1.0
        displacement *= plus_or_minus

    # Calculate the final size with displacement
    var output = round(_size + displacement)

    # Debugging output
    print("Certainty:", certainty)
    print("Uncertainty factor:", uncertainty_factor)
    print("Displacement:", displacement)
    print("Output size:", output)

    return output
    
        
