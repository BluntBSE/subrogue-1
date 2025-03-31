@tool
extends TextureProgressBar
class_name DraggableTPB
#Intended to work with the draggableTPB.tres material and DraggableTPB.gdshader
#Supply a texture to the built-in "under", and also to the shader parameters.
@export var num_handles: int = 1  # 1 or 2
@export var handle_1: Node
@export var handle_2: Node
var handle_1_active:bool = false
var handle_2_active:bool = false
signal handle_values #{"left":0.0, "right":1.0}

func _process(_delta:float):
    update_handles()
    


#If only handle_1 is assigned, treat the bar as only able to move the max value
#If both are assigned, handle_1 moves the max, handle_2 moves the min.
func update_handles()->void:
    #One-handle behavior
    if handle_2 == null:
        if handle_1_active == true:
            var mouse_pos = get_global_mouse_position()
            print("Right handle moving")
            var left_boundary = global_position.x
            var right_boundary = global_position.x+size.x
            handle_1.global_position.x = clamp(left_boundary, mouse_pos.x, right_boundary)
            
            
        

func _on_range_bar_control_max_pressed() -> void:
    print("Rightmost handle should be active")
    handle_1_active = true
    pass # Replace with function body.


func _on_range_bar_control_max_button_up() -> void:
    handle_1_active = false
    pass # Replace with function body.
