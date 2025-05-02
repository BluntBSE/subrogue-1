@tool
extends TextureProgressBar
class_name DraggableTPB
#Intended to work with the draggableTPB.tres material and DraggableTPB.gdshader
#Supply a texture to the built-in "under", and also to the shader parameters.
@export var num_handles: int = 1  # 1 or 2
@export var handle_1: Node
@export var handle_2: Node
@export var output_label:Label
@export var mult_factor:float
@export var output_symbol:String

var handle_1_active:bool = false
var handle_2_active:bool = false

var base_max:float = 1.0
var base_min:float = 0.0

var externally_overriden:bool = false #Turns to "true" when an otuside force acts on this.

signal handle_values #{"min":0.0, "max":1.0}

func log_values(vals:Dictionary):
    print(vals)

func update_output(vals:Dictionary)->void:
    if handle_2 == null:
        output_label.text = str(snapped(vals.max * mult_factor,0.1) ) + output_symbol
    else:
        output_label.text = str( snapped(vals.min * mult_factor,0.1) )+ output_symbol + " - " + str(snapped(vals.max * mult_factor,0.1) )

func _ready()->void:
    handle_values.connect(log_values)
    handle_values.connect(update_output)


func _process(_delta:float):
    update_handles()
    


#If only handle_1 is assigned, treat the bar as only able to move the max value
#If both are assigned, handle_1 moves the max, handle_2 moves the min.
func update_handles()->void:
    #If only one handle is active, it MUST be handle 1.
    if handle_2 != null and handle_1 == null:
        return
    #One-handle behavior
    if handle_2 == null:
        if handle_1_active == true:
            var mouse_pos = get_global_mouse_position()
            var handle_width = handle_1.size.x * handle_1.scale.x
            var right_boundary = global_position.x+size.x - (handle_width/2)
            var left_boundary = global_position.x - (handle_width/2)
            handle_1.global_position.x = clamp(left_boundary, mouse_pos.x, right_boundary)
            var base_out = lerp(0.0, 1.0, (handle_1.global_position.x  - left_boundary)/(right_boundary-left_boundary) )      
            handle_values.emit({"min": 0.0, "max": base_out})
            set_instance_shader_parameter("left_percent", 0.0)
            set_instance_shader_parameter("right_percent", base_out)
    if handle_1 != null and handle_2 != null:

        
        if handle_1_active == true:
            var mouse_pos = get_global_mouse_position()
            var handle_width = handle_1.size.x * handle_1.scale.x
            var right_boundary = global_position.x+size.x - (handle_width/2)
            var left_boundary = global_position.x + (handle_width/2)
            handle_1.global_position.x = clamp(left_boundary, mouse_pos.x, right_boundary)
            #The below should probably be its own function.
            base_max = lerp(0.0, 1.0, (handle_1.global_position.x  - left_boundary)/(right_boundary-left_boundary) )
            handle_values.emit({"min": base_min, "max": base_max})  
            set_instance_shader_parameter("left_percent", base_min)
            set_instance_shader_parameter("right_percent", base_max)

        if handle_2_active == true:
            var mouse_pos = get_global_mouse_position()
            var handle_width = handle_1.size.x * handle_1.scale.x
            var right_boundary = global_position.x+size.x - (handle_width/2)
            var left_boundary = global_position.x - (handle_width/2)
            handle_2.global_position.x = clamp(left_boundary, mouse_pos.x, right_boundary)
            #The below should probably be its own function.
            base_min = lerp(0.0, 1.0,(handle_2.global_position.x  - left_boundary)/(right_boundary-left_boundary) )   
            handle_values.emit({"min": base_min, "max": base_max})  
            set_instance_shader_parameter("left_percent", base_min)
            set_instance_shader_parameter("right_percent", base_max)   
            pass
            
            

#TODO: Add an external adjust values thing here. 

func _on_range_bar_control_max_pressed() -> void:
    handle_1_active = true
    pass # Replace with function body.


func _on_range_bar_control_max_button_up() -> void:
    handle_1_active = false
    pass # Replace with function body.


func _on_range_bar_control_min_pressed() -> void:
    handle_2_active=true
    
    pass # Replace with function body.


func _on_range_bar_control_min_button_up() -> void:
    handle_2_active=false
    pass # Replace with function body.
