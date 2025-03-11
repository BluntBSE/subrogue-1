extends Node3D
@onready var load_filter:ColorRect = %OnLoadFilter


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    if load_filter != null:
        if is_equal_approx(load_filter.modulate.a, 0.0):
            load_filter.visible = false
            load_filter.queue_free()
            return
        load_filter.modulate.a = lerp(load_filter.modulate.a, 0.0, delta * 0.5)

    pass
    
func _unhandled_input(event: InputEvent) -> void:
    print(event)
