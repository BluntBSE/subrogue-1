extends Node3D
class_name EntityDetector

#Passive detection stats
@onready var entity:Entity = get_parent()
@onready var detection_area = %DetectionArea
var detection_parent:EntityDetector = null #Used for ordnance that updates detection for its parent.
var sensitivity:float = 5.0 #Expressed as minimum DB to hear
var c100:float = 300.0 #Expressed as km
var cfalloff:float = 0.2 #Certainty lost per 10km.
var min_certainty: float = 20.0 #Always at least 20% certain in detection position
var max_range:float = 2000.0 #Expressed as km
var positively_identified = [] #Signals from this source will always be marked if the profile, etc. is the same.
var tracked_entities = [] #{"entity":entity, "tracked_by":[self, child, child]}
var local_entities = []#Used for situations where we want to think about what this munition sees ONLY
var known_signals = [] 
var sigmap = {} # {"entity":entity, "signal":signal} Signals match to the array below, which we for updating those independently.

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    if entity is Munition:
        #This means that the detector (for now) is totally subordinate to its parent.
        #Bind to the detection node of the originating entity
        detection_parent = entity.fired_from.detector
    pass # Replace with function body.

var poll_elapsed: float = 0.0
func _process(delta: float) -> void:
    poll_elapsed += delta
    if poll_elapsed > 2.0: # Polling frequency
        poll_elapsed = 0.0
       # poll_entities()

func is_already_tracked(_entity:Entity, entity_list:Array)->bool:
    var is_tracked = false
    for track_obj:Dictionary in entity_list:
        if track_obj.entity == _entity:
            is_tracked = true
    return is_tracked

func _on_detection_area_body_entered(body: Node3D) -> void:
    if body is Entity and body != entity:
        body = body as Entity
        #Check if body is already tracked
        #Don't track things belonging to your own faction, you already know where they are.
        if body.faction == entity.faction:
            return
        #'Tracked' represents only the fact that body can be polled for whether or not it is visible.
        var tracked:bool = is_already_tracked(body, tracked_entities)
        
            
        print(entity.name + " detector just saw " + body.name + " enter ")
        if detection_parent == null:
            #If this is a vessel, not a munition or sub entity, tracked items are associated with the vessel directly
                    
            if tracked == false:
                var track_obj = {"entity":body, "tracked_by":[self]}
                tracked_entities.append(track_obj)
                body.died.connect(handle_tracked_object_died)
                print("Added ", body.name, "to own tracked entities, tracked by ", self)
                 #DEBUG - Signal test
                var signal_scene = preload("res://engine/entities/detection/signal_popup_3d.tscn").instantiate()
                signal_scene.global_position = body.global_position           
                entity.anchor.add_child(signal_scene)
            if tracked == true: #Check to see if this entity is tracking it. It might be tracked only by a subentity
               var tracked_by_this = false
               for track_obj in tracked_entities:
                    if track_obj.entity == body:
                        if !track_obj.tracked_by.has(self): 
                            track_obj.tracked_by.append(self)
                            
        if detection_parent:
            #Local tracking of munition's contacts, not shared with parent but used in homing calculations.
            #Essentially a local-only tracked_entities.
            if body not in local_entities:
                if body.faction != entity.faction:
                    local_entities.append(body)
                    
            #See if the parent is already seeing this
            tracked = is_already_tracked(body, detection_parent.tracked_entities)
                    
            if tracked == false:
                var track_obj = {"entity":body, "tracked_by":[self]}
                detection_parent.tracked_entities.append(track_obj)
                body.died.connect(detection_parent.handle_tracked_object_died)
                print("Added ", body.name, "to tracked entities of parent: ,", detection_parent, "tracked by ", self)




            
func poll_entities():
    # Every few seconds, calculate the sound that would reach this node, the listener, based on the body's emitter
    if detection_parent == null: # Child detectors don't do their own polling; they leave it to their parents
        for dict: Dictionary in tracked_entities:
            #If the entity no longer exists because it died or docked, discard it.
            if dict.entity == null:
                tracked_entities.erase(dict)
                continue
            var max_certainty = 0.0
            var most_certain_detector = null
            var emission: EntityEmission = dict.entity.emission
            var sound = Sound.new(dict.entity, dict.entity.emission.volume, dict.entity.emission.pitch, dict.entity.emission.profile)

            # Iterate through all detectors in `tracked_by`
            for detector in dict.tracked_by:
                # Check sound for this detector
                var dist = GlobeHelpers.arc_to_km(detector.entity.position, dict.entity.position, detector.entity.anchor)
                var final_db = GlobalConst.attenuate_sound(sound.volume, sound.pitch, dist)

                if final_db >= sensitivity:
                    # Calculate certainty using the new function
                    var certainty = calculate_certainty(dist, c100, cfalloff, min_certainty)

                    # Track the detector with the highest certainty
                    if certainty > max_certainty:
                        max_certainty = certainty
                        most_certain_detector = detector

            # Update the signal object with the highest certainty
            if max_certainty > 0.0:
                if !sigmap.has(dict.entity):
                    var sigob: SignalObject = load("res://engine/entities/detection/signal_scene.tscn").instantiate()
                    sigob.unpack(most_certain_detector.entity, dict.entity, sound, max_certainty)
                    entity.anchor.add_child(sigob)
                    sigmap[dict.entity] = sigob

                sigmap[dict.entity].certainty = max_certainty
                sigmap[dict.entity].tween_to_new()

                # If the most certain detector is not `self`, call `turn_red()`
                if most_certain_detector != self:
                    sigmap[dict.entity].turn_red()

                # Handle visibility and identification
                var dist = GlobeHelpers.arc_to_km(entity.position, dict.entity.position, entity.anchor)
                if dist <= c100:
                    dict.entity.render.update_mesh_visibilities(entity.faction, true)
                    positively_identified.append(dict.entity)
                    sigmap[dict.entity].visible = false
                elif dist > c100 + 50.0:
                    if sigmap[dict.entity].visible == false:
                        sigmap[dict.entity].visible = true
                        dict.entity.render.update_mesh_visibilities(entity.faction, false)
                        
func calculate_certainty(dist: float, c100: float, cfalloff: float, min_certainty: float) -> float:
    # Calculate certainty based on distance
    var certainty: float
    var from_c100 = (dist - c100)
    if from_c100 > 0:
        certainty = 100 - (cfalloff * from_c100)
    else:
        certainty = 100.0

    # Ensure minimum certainty
    if certainty < min_certainty:
        certainty = min_certainty

    return certainty        

func handle_tracked_object_died(_entity:Entity)->void:
    print("Detector is handling target died")
    local_entities.erase(_entity)
    for dict:Dictionary in tracked_entities:
        if dict.entity == _entity:
            tracked_entities.erase(dict)
    pass
    
