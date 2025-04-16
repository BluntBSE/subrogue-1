class_name NameGenerator
# Predefined lists of words for generating names
const PREFIXES = ["Boundless", "Ocean", "Endless", "Silent", "Stormy", "Golden", "Eternal", "Wandering"]
const SUFFIXES = ["Horizon", "Crest", "Voyager", "Tide", "Dream", "Whisper", "Odyssey", "Spirit"]
const SINGLE_NAMES = ["Cynthia", "Aurora", "Neptune", "Poseidon", "Luna", "Mariner", "Atlantis", "Serenity"]

# Function to generate a random name
static func generate_name() -> String:
    var name_type = randi() % 2 # Randomly decide between compound or single name
    if name_type == 0:
        # Generate a compound name (e.g., "Boundless Horizon")
        var prefix = PREFIXES[randi() % PREFIXES.size()]
        var suffix = SUFFIXES[randi() % SUFFIXES.size()]
        return prefix + " " + suffix
    else:
        # Generate a single name (e.g., "Cynthia")
        return SINGLE_NAMES[randi() % SINGLE_NAMES.size()]
