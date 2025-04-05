extends Node
class_name Notifications

var observers:Array = []

func _ready() -> void:
    #I can't think of any reason not to always engage the game observer, so:
    var game_observer:GameObserver = get_tree().root.find_child("GameObserver", true, false)
    add_observer(game_observer)

func notify(event:Object)->void:
    #Events are enum in GameObserver like GameObserver.events.ENTITY_DIED
    for observer in observers:
        observer.on_notify(event)
    

func add_observer(observer:Node)->void:
    observers.append(observer)

func remove_observer(observer:Node)->void:
    observers.erase(observer)
