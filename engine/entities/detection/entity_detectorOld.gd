extends Node3D
class_name EntityDetectorOld

# Passive detection stats
@onready var entity: Entity = get_parent()
@onready var detection_area = %DetectionArea
var detection_parent: EntityDetector = null # Used for ordnance that updates detection for its parent
var sensitivity: float = 5.0 # Minimum DB to hear
var c100: float = 300.0 # Certainty range in km
var cfalloff: float = 0.2 # Certainty lost per 10km
var min_certainty: float = 20.0 # Minimum certainty
var max_range: float = 2000.0 # Maximum detection range in km
var positively_identified = [] # Signals always marked if profile matches
var tracked_entities = [] # {"entity": entity, "tracked_by": [self, child, child]}
var local_entities = [] # Used for local detection (e.g., munitions)
var sigmap = {} # {"entity": entity, "signal": signal_object}

var poll_elapsed: float = 0.0

# Called when the node enters the scene tree for the first time
func _ready() -> void:
    if entity is Munition:
        detection_parent = entity.fired_from.detector

# Called every frame
func _process(delta: float) -> void:
    poll_elapsed += delta
    if poll_elapsed > 2.0: # Polling frequency
        poll_elapsed = 0.0
        poll_entities()

# Handle when a body enters the detection area
func _on_detection_area_body_entered(body: Node3D) -> void:
    if body is Entity and body != entity:
        body = body as Entity
        print(entity.name + " detector saw " + body.name + " enter")
        if detection_parent:
            handle_local_tracking(body)
        else:
            handle_global_tracking(body)

# Handle global tracking (parentless detectors)
func handle_global_tracking(body: Entity) -> void:
    if is_already_tracked(body, tracked_entities):
        add_to_tracked_by(body, tracked_entities)
    else:
        if body.faction != entity.faction:
            add_to_tracked_entities(body, tracked_entities)
            body.died.connect(handle_tracked_object_died)

# Handle local tracking (child detectors)
func handle_local_tracking(body: Entity) -> void:
    if body not in local_entities and body.faction != entity.faction:
        local_entities.append(body)

    if is_already_tracked(body, detection_parent.tracked_entities):
        add_to_tracked_by(body, detection_parent.tracked_entities)
    else:
        if body.faction != entity.faction:
            add_to_tracked_entities(body, detection_parent.tracked_entities)
            body.died.connect(detection_parent.handle_tracked_object_died)

# Check if an entity is already tracked
func is_already_tracked(body: Entity, tracked_list: Array) -> bool:
    for track_obj in tracked_list:
        if track_obj.entity == body:
            return true
    return false

# Add an entity to the tracked list
func add_to_tracked_entities(body: Entity, tracked_list: Array) -> void:
    var track_obj = {"entity": body, "tracked_by": [self]}
    tracked_list.append(track_obj)
    print("Added", body.name, "to tracked entities")

# Add this detector to the "tracked_by" list for an entity
func add_to_tracked_by(body: Entity, tracked_list: Array) -> void:
    for track_obj in tracked_list:
        if track_obj.entity == body and !track_obj.tracked_by.has(self):
            track_obj.tracked_by.append(self)

# Poll entities to calculate certainty and update signals
func poll_entities() -> void:
    if detection_parent == null: # Only parentless detectors poll
        for dict in tracked_entities:
            if dict.entity == null:
                tracked_entities.erase(dict)
                continue

            var max_certainty = 0.0
            var most_certain_detector = null
            var sound = create_sound(dict.entity)

            for detector in dict.tracked_by:
                if dict.entity == null or dict.tracked_by == null:
                    continue

                var dist = GlobeHelpers.arc_to_km(detector.entity.position, dict.entity.position, detector.entity.anchor)
                var final_db = GlobalConst.attenuate_sound(sound.volume, sound.pitch, dist)

                if final_db >= sensitivity:
                    var certainty = calculate_certainty(dist)
                    if certainty > max_certainty:
                        max_certainty = certainty
                        most_certain_detector = detector

            update_signal(dict.entity, most_certain_detector, max_certainty, sound)

# Create a sound object for an entity
func create_sound(entity: Entity) -> Sound:
    return Sound.new(entity, entity.emission.volume, entity.emission.pitch, entity.emission.profile)

# Update the signal object for an entity
func update_signal(entity: Entity, detector: EntityDetector, certainty: float, sound: Sound) -> void:
    if certainty > 0.0:
        if !sigmap.has(entity):
            var sigob: SignalObject = load("res://engine/entities/detection/signal_scene.tscn").instantiate()
            sigob.unpack(detector.entity, entity, sound, certainty)
            entity.anchor.add_child(sigob)
            sigmap[entity] = sigob

        sigmap[entity].certainty = certainty
        sigmap[entity].tween_to_new()

        if detector != self:
            sigmap[entity].turn_red()

        handle_visibility(entity, certainty)

# Handle visibility and identification
func handle_visibility(entity: Entity, certainty: float) -> void:
    var dist = GlobeHelpers.arc_to_km(self.entity.position, entity.position, self.entity.anchor)
    if dist <= c100:
        entity.render.update_mesh_visibilities(entity.faction, true)
        positively_identified.append(entity)
        sigmap[entity].visible = false
    elif dist > c100 + 50.0:
        if !sigmap[entity].visible:
            sigmap[entity].visible = true
            entity.render.update_mesh_visibilities(entity.faction, false)

# Calculate certainty based on distance
func calculate_certainty(dist: float) -> float:
    var certainty = 100.0 - (cfalloff * max(0.0, dist - c100))
    return max(certainty, min_certainty)

# Handle when a tracked object dies
func handle_tracked_object_died(_entity: Entity) -> void:
    print("Detector handling target died:", _entity.name)
    local_entities.erase(_entity)
    for dict in tracked_entities:
        if dict.entity == _entity:
            tracked_entities.erase(dict)
        if dict.tracked_by.has(_entity):
            print("Removing ", _entity, "from tracked by dict: ", dict)
            dict.tracked_by.erase(_entity)
