extends Node
class_name EntityPool
@onready var tsm:TSM = %TestSceneManager
var buffer_size = 100 #You never know!
@onready var max_entities = tsm.num_commercial_entities + buffer_size
var pool:Array = []

func begin():
    for i in range(max_entities):
        var new_entity:Entity = preload("res://engine/entities/generic_entity.tscn").instantiate()
        new_entity.died.connect(handle_entity_died)
        pool.append(new_entity)
        add_child(new_entity)
        pass
        
func _ready():
    begin()
    
func serve():
    print("Served from pool")
    var entity = pool.pop_front()
    print("Served from pool. Pool size is now", pool.size())
    return entity
    #Eventually this needs to handle the pool being empty.

func handle_entity_died(entity:Entity):
    var parent = entity.get_parent()
    entity.reparent(self, false)
    entity.sleep()
    pool.append(entity)
    print("Returned entity ", entity.name, "to pool. Pool size is now: ", pool.size())
