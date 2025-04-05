extends Node
class_name GameObserver
#The purpose of this node is to provide a stream of all events that do have global consequences
#Entities dying for score reasons, diplomacy incidents, etc.
#Anything that wants to listen to this stream connects to the "event" signal
#And matches to see if the event is of a class that it cares about.
#EVENT TYPES

var queue:Array = []

signal event

func process(delta:float)->void:
    if queue.size()>0:
        var processed_event = queue.pop_front()
        event.emit(processed_event)
        processed_event.queue_free()
    
func on_notify(event:Object)->void:
    if event not in queue:
        queue.append(event)

func broadcast(event:Object)->void:
    event.emit(event)
