extends Node3D
class_name EntityDetector

#Passive detection stats
@onready var entity:Entity = get_parent()
@onready var detection_area = %DetectionArea
var detection_parent:Entity = null #Used for ordnance that updates detection for its parent.
var sensitivity:float = 5.0 #Expressed as minimum DB to hear
var c100:float = 300.0 #Expressed as km
var cfalloff:float = 0.2 #Certainty lost per 10km.
var min_certainty: float = 20.0 #Always at least 20% certain in detection position
var max_range:float = 2000.0 #Expressed as km
var positively_identified = [] #Signals from this source will always be marked if the profile, etc. is the same.
var tracked_entities = [] #{"entity":entity, "tracked_by":[self, child, child]}
var known_signals = [] 
var sigmap = {} # {"entity":entity, "signal":signal} Signals match to the array below, which we for updating those independently.

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    if entity is Munition:
        entity as Munition
        #This means that the detector (for now) is totally subordinate to its parent.
        detection_parent = entity.fired_from
        print("DETECTION PARENT IS", detection_parent)
    pass # Replace with function body.

var poll_elapsed:float = 0.0
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    var polling_frequency = 3.0
    poll_elapsed += delta
    if poll_elapsed > polling_frequency:
        poll_elapsed = 0.0
        poll_entities()
    
    #poll_bodies
    #update_signals
    pass


func _on_detection_area_body_entered(body: Node3D) -> void:
    if body is Entity and body != entity:
        body as Entity
        #Check if body is already tracked
        print(entity.name + " detector just saw " + body.name + " enter ")
        if detection_parent == null:
            #If this is a vessel, not a munition or sub entity, tracked items are associated with the vessel
            var tracked = false
            for track_obj in tracked_entities:
                if track_obj.entity == body:
                    tracked = true
                    
            if tracked == false:
                #This represents only the fact that body is being polled for whether or not it is visible.
                var track_obj = {"entity":body, "tracked_by":[self]}
                tracked_entities.append(track_obj)
                print("Added ", body.name, "to tracked entities, tracked by ", self)
            
            if tracked == true: #Check to see if this entity is tracking it. It might be tracked only by a subentity
               var tracked_by_this = false
               for track_obj in tracked_entities:
                    if track_obj.entity == body:
                        if !track_obj.tracked_by.has(self): 
                            track_obj.tracked_by.append(self)
            #Otherwise do nothing

func poll_entities():
    #Every few seconds, calculate the sound that would reach this node, the listener, based on the body's emitter
    for dict:Dictionary in tracked_entities:
        #Check sound
        var emission:EntityEmission = dict.entity.emission
        var sound = Sound.new(dict.entity, dict.entity.emission.volume, dict.entity.emission.pitch, dict.entity.emission.profile)
        var dist = GlobeHelpers.arc_to_km(entity.position, dict.entity.position, entity.anchor)
        var final_db = GlobalConst.attenuate_sound(sound.volume, sound.pitch, dist)
        var dstr =  ("final db " +str (final_db) + "from body: " + dict.entity.name + " vs sensitivty " + str(sensitivity) )
        entity.debug.dmsg(dstr)
        
        if final_db <= sensitivity:
            print("Too quiet. Attempting to erase signal")
            #If you had the signal, you've lost it now.
            #Grace period for active pings?
            var tracked = false
            for track_obj in tracked_entities:
                if track_obj.entity == dict.entity:
                    tracked = true
            if tracked == true:
                if sigmap.has(dict.entity):
                   #tracked_entities.erase(dict.entity)
                    sigmap[dict.entity].queue_free()
                    sigmap.erase(dict.entity)

        if final_db >= sensitivity:
            #If no signal object exists, make one.
            var certainty:float
            var from_c100 =  (dist-c100)
            if from_c100 > 0: #A positive number indicates the distance is greater than c100.
                certainty = 100 - (cfalloff * (dist-c100))        
                pass
            else:
                certainty = 100.0
            var dstr2 = "Certainty is now " + str(certainty)
            entity.debug.dmsg(dstr2)
            #More fun if we're always at least 20% certain
            if certainty < 0.2:
                certainty = 0.2
            if !sigmap.has(dict.entity):
                var sigob:SignalObject = load("res://engine/entities/detection/signal_scene.tscn").instantiate()
                entity.anchor.add_child(sigob)
                sigob.unpack(entity, dict.entity, sound, certainty)
                sigmap[dict.entity] = sigob
            else:
                sigmap[dict.entity].certainty =certainty
                sigmap[dict.entity].tween_to_new()
           
            #See if the entity in is within the C100 range.
            if dist <= c100:
                #Hide the associated signal object and reveal the actual entity
                print("Entity within C100, make actively tracked")
                dict.entity.render.update_mesh_visibilities(entity.faction, true)
                positively_identified.append(dict.entity)
                sigmap[dict.entity].visible = false
                pass
            
            #If we already have a signal, and the target is drifting out of C100...
            if dist > c100 + 50.0: # 50 being an arbitrary threshold to let you keep positively identified targets around longer
                if sigmap[dict.entity].visible == false:
                    sigmap[dict.entity].visible = true
                    dict.entity.render.update_mesh_visibilities(entity.faction, false)
            
            
            pass
        else:
            #If the entity has a matching signal, but it's too quiet, now, remove that signal.
            pass
        
