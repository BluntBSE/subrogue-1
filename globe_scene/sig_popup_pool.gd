extends Node
class_name SignalPopupPool

@export var target_pool_size = 100
@export var batch_size = 5  # How many to create per frame

var pool: Array = []
var is_filling_pool = false
var creation_timer: Timer

# Signal to notify when pool is ready for use
signal pool_initialization_complete(count: int)
signal pool_initialization_progress(current: int, total: int)

func _ready():
    # Create a timer to control batch timing
    creation_timer = Timer.new()
    creation_timer.wait_time = 0.01  # 10ms between batches
    creation_timer.one_shot = false
    creation_timer.timeout.connect(_create_batch)
    add_child(creation_timer)
    
    # Start filling the pool
    call_deferred("begin")

func begin():
    print("Starting pool initialization...")
    is_filling_pool = true
    creation_timer.start()

func _create_batch():
    if !is_filling_pool or pool.size() >= target_pool_size:
        # Pool is filled or process was stopped
        is_filling_pool = false
        creation_timer.stop()
        emit_signal("pool_initialization_complete", pool.size())
        print("Pool initialization complete. Total objects: ", pool.size())
        return
    
    # Calculate how many objects to create in this batch
    var remaining = target_pool_size - pool.size()
    var to_create = min(batch_size, remaining)
    
    # Create objects in this batch
    for i in range(to_create):
        var new_signal = preload("res://engine/entities/detection/signal_popup_3d.tscn").instantiate()
        pool.append(new_signal)
        new_signal.disable()
        add_child(new_signal)
    
    # Report progress
    emit_signal("pool_initialization_progress", pool.size(), target_pool_size)
    
    # Print progress occasionally (every 10% or so)
    var percentage = float(pool.size()) / float(target_pool_size) * 100.0
    if int(percentage) % 10 == 0:
        print("Pool initialization progress: ", int(percentage), "% (", pool.size(), "/", target_pool_size, ")")

func serve():
    if pool.size() == 0:
        # Handle pool empty case
        print("WARNING: Signal popup pool empty, creating emergency instance")
        var emergency_signal = preload("res://engine/entities/detection/signal_popup_3d.tscn").instantiate()
        add_child(emergency_signal)
        return emergency_signal
    
    var signal_popup = pool.pop_front()
    return signal_popup

func handle_signal_needs_pooling(sigpopup: SignalPopup):
    sigpopup.disable()
    pool.append(sigpopup)
    sigpopup.position = Vector3(0.0, 0.0, 0.0)
    
    # Optional: Start refilling pool if it was completely empty
    if pool.size() == 1 and is_filling_pool == false and pool.size() < target_pool_size:
        print("Pool was empty, resuming initialization")
        is_filling_pool = true
        creation_timer.start()
