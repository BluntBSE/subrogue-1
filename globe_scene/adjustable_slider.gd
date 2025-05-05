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
    #Mysterious issues? Remember that you made this CEIL to git rid of the annoying 99.4 db bug
    if handle_2 == null:
        output_label.text = str(ceil(snapped(vals.max * mult_factor,0.1) )) + output_symbol
    else:
        output_label.text = str( ceil(snapped(vals.min * mult_factor,0.1) ))+ output_symbol + " - " + str(snapped(vals.max * mult_factor,0.1))

func _ready()->void:
    #handle_values.connect(log_values)
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


# Update the min or max value from an external signal
# This function handles updating both handles, shader parameters, and signals
func set_values(min_value: float = -1, max_value: float = -1) -> void:
    var updated = false
    
    # Normalize values to 0-1 range
    min_value = clamp(min_value, 0.0, 1.0)
    max_value = clamp(max_value, 0.0, 1.0)
    
    # Check which values to update
    if max_value >= 0:
        base_max = max_value
        updated = true
        
    if min_value >= 0 and handle_2 != null:
        base_min = min_value
        updated = true
        
    # Ensure min doesn't exceed max
    if handle_2 != null and base_min > base_max:
        if min_value >= 0:  # If min was explicitly set, adjust max
            base_max = base_min
        else:  # If max was explicitly set, adjust min
            base_min = base_max
    
    if updated:
        externally_overriden = true
        update_handle_positions()
        update_shader_parameters()
        handle_values.emit({"min": base_min, "max": base_max})
        externally_overriden = false

# Helper function to convert normalized value (0-1) to handle position
func value_to_position(value: float, handle: Node) -> float:
    var handle_width = handle.size.x * handle.scale.x
    var right_boundary = global_position.x + size.x - (handle_width/2)
    var left_boundary = global_position.x - (handle_width/2)
    
    # If it's handle_2 (min handle), adjust the left boundary
    if handle == handle_2:
        left_boundary = global_position.x - (handle_width/2)
    else:  # For handle_1 (max handle)
        left_boundary = global_position.x + (handle_width/2)
    
    return left_boundary + value * (right_boundary - left_boundary)

# Update handle positions based on current base_min and base_max values
func update_handle_positions() -> void:
    if handle_1 != null:
        # Update handle_1 (max) position
        handle_1.global_position.x = value_to_position(base_max, handle_1)
    
    if handle_2 != null:
        # Update handle_2 (min) position
        handle_2.global_position.x = value_to_position(base_min, handle_2)

# Update shader parameters
func update_shader_parameters() -> void:
    if handle_2 == null:
        # Single handle mode
        set_instance_shader_parameter("left_percent", 0.0)
        set_instance_shader_parameter("right_percent", base_max)
    else:
        # Dual handle mode
        set_instance_shader_parameter("left_percent", base_min)
        set_instance_shader_parameter("right_percent", base_max)

# Convenience functions for individual value updates
func set_max_value(value: float) -> void:
    set_values(-1, value)

func set_min_value(value: float) -> void:
    set_values(value, -1)
