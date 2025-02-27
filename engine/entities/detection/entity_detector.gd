extends Node3D
class_name EntityDetector

#Passive detection stats
@onready var entity = get_parent()
@onready var detection_area = %DetectionArea
var sensitivity:float = 20.0 #Expressed as minimum DB to hear
var c100:float = 300.0 #Expressed as km
var cfalloff:float = 1.0 #Certainty lost per 10km.
var min_certainty: float = 20.0 #Always at least 20% certain in detection position
var max_range:float = 2000.0 #Expressed as km

var tracked_entities = [] 
var known_signals = [] 
var sigmap = {} # {"entity":entity, "signal":signal} Signals match to the array below, which we for updating those independently.

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass


func _on_detection_area_body_entered(body: Node3D) -> void:
    if body is Entity and body != entity:
        body as Entity
        #Check if body is already tracked
        print(entity.name + " detector just saw " + body.name + " enter ")
        if body not in tracked_entities:
            tracked_entities.append(body)
            var sigob = load("res://engine/entities/detection/signal_scene.tscn").instantiate()
            entity.anchor.add_child(sigob)
            print("Detection area parent: ", entity)
            sigob.unpack(entity,body)

            
        pass
    pass # Replace with function body.
