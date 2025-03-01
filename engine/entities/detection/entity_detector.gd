extends Node3D
class_name EntityDetector

#Passive detection stats
@onready var entity:Entity = get_parent()
@onready var detection_area = %DetectionArea
var sensitivity:float = 5.0 #Expressed as minimum DB to hear
var c100:float = 300.0 #Expressed as km
var cfalloff:float = 0.2 #Certainty lost per 10km.
var min_certainty: float = 20.0 #Always at least 20% certain in detection position
var max_range:float = 2000.0 #Expressed as km

var positively_identified = [] #Signals from this source will always be marked if the profile, etc. is the same.
var tracked_entities = [] 
var known_signals = [] 
var sigmap = {} # {"entity":entity, "signal":signal} Signals match to the array below, which we for updating those independently.

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
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
        if body not in tracked_entities:
            #This represents only the fact that body is being polled for whether or not it is visible.
            tracked_entities.append(body)
            print("Added ", body.name, "to tracked entities")
            
           # var sigob:SignalObject = load("res://engine/entities/detection/signal_scene.tscn").instantiate()
            #entity.anchor.add_child(sigob)
           # print("Detection area parent: ", entity)
            #sigob.unpack(entity,body,)

            
        pass
    pass # Replace with function body.
    
func poll_entities():
    #Every few seconds, calculate the sound that would reach this node, the listener, based on the body's emitter
    for poll_entity:Entity in tracked_entities:
        #Check sound
        var emission:EntityEmission = poll_entity.emission
        var sound = Sound.new(poll_entity, poll_entity.emission.volume, poll_entity.emission.pitch, poll_entity.emission.profile)
        var dist = GlobeHelpers.arc_to_km(entity.position, poll_entity.position, entity.anchor)
        var final_db = GlobalConst.attenuate_sound(sound.volume, sound.pitch, dist)
        var dstr =  ("final db " +str (final_db) + "from body: " + poll_entity.name + " vs sensitivty " + str(sensitivity) )
        entity.debug.dmsg(dstr)

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
            if !sigmap.has(poll_entity):
                var sigob:SignalObject = load("res://engine/entities/detection/signal_scene.tscn").instantiate()
                entity.anchor.add_child(sigob)
                sigob.unpack(entity, poll_entity, sound, 50.0)
                sigmap[poll_entity] = sigob
            else:
                sigmap[poll_entity].certainty =certainty
           
            #sigob.unpack(entity,body,)           
            #See if the entity in questin is within the C100 range.
            if dist <= c100:
                print("Entity within C100, make actively tracked")
                poll_entity.render.update_mesh_visibilities(entity.faction, true)
                positively_identified.append(poll_entity)
                sigmap[poll_entity].visible = false
                pass
            #If the entity has no matching signal, make one.
            
            
            pass
        else:
            #If the entity has a matching signal, but it's too quiet, now, remove that signal.
            pass
        
