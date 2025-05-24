extends Node3D
class_name EntityDetector

#Passive detection stats
var entity:Entity
@onready var detection_area = %DetectionArea
var detection_parent:EntityDetector = null #Used for ordnance that updates detection for its parent.
var sensitivity:float = 5.0 #Expressed as minimum DB to hear
var c100:float = 200.0 #Expressed as km
var cfalloff:float = 0.15 #Certainty lost per 10km.
var min_certainty: float = 10.0 #Always at least 10% certain in detection position
var max_range:float = 2000.0 #Expressed as km
#Signals themselves carry a positively_identified signal. We might not neeed the array here.
var positively_identified = [] #Signals from this source will always be marked if the profile, etc. is the same.
var tracked_entities = [] #{"entity":entity, "tracked_by":[self, child, child]}
var local_entities = []#Used for situations where we want to think about what this munition sees ONLY
var known_signals = [] 
var sigmap = {} # {entity rigid object as key: signalpopup} Signals match to the array below, which we for updating those independently.
var archive_map = {}





# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    pass


var poll_elapsed = 0.0
var poll_active = false
var poll_frequency

func unpack(_entity:Entity):
    print("Unpack called with ", _entity.name)
    entity = _entity
    if entity.is_player == true:
        poll_active = true
        poll_frequency = 0.25
    else:
        #Just for testing slowdown
        poll_active = true
        poll_frequency = 0.25      
        
    if entity is Munition:
        #This means that the detector (for now) is totally subordinate to its parent.
        #Bind to the detection node of the originating entity
        detection_parent = entity.fired_from.detector
    
    pass
    
func _process(delta: float) -> void:
    #DEBUG: RIGHT NOW ONLY PLAYERS CAN DETECT. THAT"S NOT WHAT WE WANT IN THE END.
    poll_elapsed += delta
    #PROPOSED OVERHAUL FOR WHEN WE NEED TO OPTIMIZE:
    #You can't make signal nodes from a separate thread, but you could, once a signal is created,
    #Have that signal update itself on a new thread. That means moving the polling logic from the detector, here,
    #To the signalpopup, with a little duplication between them (the detector must run the check once. The sigobj must run it constantly
    #Until we get to the trailer, though, we'll do this very ugly following:
    if poll_active == true:
        if poll_elapsed >= poll_frequency:
                poll_elapsed = 0.0
                poll_entities()
  


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
        
            
        if detection_parent == null:
            #If this is a vessel, not a munition or sub entity, tracked items are associated with the vessel directly
            if tracked == false:
                var track_obj = {"entity":body, "tracked_by":[self]}
                tracked_entities.append(track_obj)
                body.died.connect(handle_tracked_object_died)
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


            
func poll_entities():
    if detection_parent == null:
        for dict: Dictionary in tracked_entities:
            if dict.entity == null:
                tracked_entities.erase(dict)
                continue
            DETECTOR_poll_single_entity(dict)

func DETECTOR_poll_single_entity(dict: Dictionary) -> void:
    var max_certainty = 0.0
    var most_certain_detector = null
    var emission: EntityEmission = dict.entity.emission
    var sound = Sound.new(dict.entity, dict.entity.emission.volume, dict.entity.emission.pitch, dict.entity.emission.profile)

    for detector in dict.tracked_by:
        if detector == null:
            dict.tracked_by.erase(detector)
            continue
        var dist = GlobeHelpers.arc_to_km(detector.entity.position, dict.entity.position, detector.entity.anchor)
        var final_db = GlobalConst.attenuate_sound(sound.volume, sound.pitch, dist)
        if final_db >= sensitivity:
            var certainty = calculate_certainty(dist, c100, cfalloff, min_certainty)
            if certainty > max_certainty:
                max_certainty = certainty
                most_certain_detector = detector

    if max_certainty <= 0.0:
        DETECTOR_archive_signal(dict)
    else:
        DETECTOR_update_or_create_signal(dict, most_certain_detector, sound, max_certainty)
        DETECTOR_update_signal_properties(dict, sound, max_certainty)
        DETECTOR_handle_identification(dict, most_certain_detector)

func DETECTOR_archive_signal(dict: Dictionary) -> void:
    if sigmap.has(dict.entity):
        var sigob: SignalPopup = sigmap[dict.entity]
        sigob.disable()
        archive_map[dict.entity] = sigob
        sigmap.erase(dict.entity)
        
func DETECTOR_instantiate_signal():
    var sigob: SignalPopup = preload("res://engine/entities/detection/signal_popup_3d.tscn").instantiate()
    return sigob

func DETECTOR_erase_signal(entity):
    archive_map.erase(entity)


func DETECTOR_update_or_create_signal(dict: Dictionary, most_certain_detector, sound, max_certainty: float) -> void:
    if !sigmap.has(dict.entity):
        if !archive_map.has(dict.entity):
            #var sigob: SignalPopup = preload("res://engine/entities/detection/signal_popup_3d.tscn").instantiate()
            var sigob = DETECTOR_instantiate_signal()
            #entity.anchor.add_child(sigob)
            sigob.unpack(most_certain_detector.entity, dict.entity, sound, max_certainty)
            sigmap[dict.entity] = sigob
            DETECTOR_maybe_play_acquire_sound()
        else:
            var sigob: SignalPopup = archive_map[dict.entity]
            sigmap[dict.entity] = sigob
            DETECTOR_erase_signal(dict.entity)
            #archive_map.erase(dict.entity)
            sigob.unpack(most_certain_detector.entity, dict.entity, sound, max_certainty)
            DETECTOR_maybe_play_acquire_sound()

func DETECTOR_update_signal_properties(dict: Dictionary, sound, max_certainty: float) -> void:
    sigmap[dict.entity].certainty = max_certainty
    sigmap[dict.entity].sound = sound

func DETECTOR_handle_identification(dict: Dictionary, most_certain_detector) -> void:
    var dist = GlobeHelpers.arc_to_km(entity.position, dict.entity.position, entity.anchor)
    if dist <= c100:
        if entity.is_player and entity.get_multiplayer_authority() == get_multiplayer_authority():
            dict.entity.render.update_mesh_visibilities(entity.faction.faction_layer, true)
        sigmap[dict.entity].positively_identify()
        sigmap[dict.entity].visible = false
    elif dist > c100 + 50.0:
        if sigmap[dict.entity].visible == false:
            sigmap[dict.entity].visible = true
        if entity.is_player and entity.get_multiplayer_authority() == get_multiplayer_authority():
            dict.entity.render.update_mesh_visibilities(entity.faction.faction_layer, false)

func DETECTOR_maybe_play_acquire_sound():
    if entity.is_player and (entity.get_multiplayer_authority() == get_multiplayer_authority()):
        SoundManager.play("signal_acquired_1")
  
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
   # print("Detector is handling target died")
    local_entities.erase(_entity)
    for dict:Dictionary in tracked_entities:
        if dict.entity == _entity:
            tracked_entities.erase(dict)
    pass
    


func _on_detection_area_body_exited(body: Entity) -> void:
    for dict in tracked_entities:
        if dict.entity == body:
            body.died.disconnect(handle_tracked_object_died)
            tracked_entities.erase(dict)
    pass # Replace with function body.
