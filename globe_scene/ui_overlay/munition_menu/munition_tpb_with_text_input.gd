@tool
extends TextureProgressBar
class_name MTPBWithText #Munition Texture Progress Bar With Text

#Intended to work with the draggableTPB.tres material and DraggableTPB.gdshader
#Supply a texture to the built-in "under", and also to the shader parameters.
@export var num_handles: int = 1  # 1 or 2
@export var handle_1: Node
@export var handle_2: Node
@export var output_label:Label
@export var deviation_label:Label
@export var typed_input:LineEdit
@export var mult_factor:float
@export var output_symbol:String
@export var minimum_deviation:float #0.0 to 1.0
var handle_1_active:bool = false
var handle_2_active:bool = false

var base_max:float = 1.0
var base_min:float = 0.0

var externally_overriden:bool = false #Turns to "true" when an otuside force acts on this.

signal handle_values #{"min":0.0, "max":1.0}


# Make sure this is connected in _ready
func _ready()->void:
    handle_values.connect(update_output)
    handle_values.connect(set_text_when_handles_moved)
    unpack(0.04)

# Update LineEdit text when handles move
func set_text_when_handles_moved(vals:Dictionary)->void:
    if externally_overriden:
        return
        
    # Calculate midpoint between min and max
    var midpoint = (vals.min + vals.max) / 2.0
    
    # Convert to display value and update LineEdit
    var display_value = snapped(midpoint * mult_factor, 0.1)
    typed_input.text = str(display_value)
    
func unpack(_minimum_deviation:float):
    minimum_deviation = _minimum_deviation
    deviation_label.text = "Minimum deviation: " + str(snapped(minimum_deviation * mult_factor, 0.001)) + output_symbol
    


func log_values(vals:Dictionary):
    print(vals)

func update_output(vals:Dictionary)->void:
    #Mysterious issues? Remember that you made this CEIL to git rid of the annoying 99.4 db bug
    if handle_2 == null:
        output_label.text = str(ceil(snapped(vals.max * mult_factor,0.1) )) + output_symbol
    else:
        output_label.text = str(snapped(vals.min * mult_factor,0.1) )+ output_symbol + " - " + str(snapped(vals.max * mult_factor,0.1))




func _process(_delta:float):
    update_handles()
    


#If only handle_1 is assigned, treat the bar as only able to move the max value
#If both are assigned, handle_1 moves the max, handle_2 moves the min.

# Enforce minimum deviation in handle movement
func update_handles()->void:
    #If only one handle is active, it MUST be handle 1.
    if handle_2 != null and handle_1 == null:
        return
    #One-handle behavior
    if handle_2 == null:
        # Single handle code - unchanged
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
        # Two handle code - need to enforce minimum deviation
        if handle_1_active == true:
            var mouse_pos = get_global_mouse_position()
            var handle_width = handle_1.size.x * handle_1.scale.x
            var right_boundary = global_position.x+size.x - (handle_width/2)
            var left_boundary = global_position.x + (handle_width/2)
            handle_1.global_position.x = clamp(left_boundary, mouse_pos.x, right_boundary)
            
            # Calculate new base_max
            var new_max = lerp(0.0, 1.0, (handle_1.global_position.x - left_boundary)/(right_boundary-left_boundary))
            
            # Enforce minimum deviation
            if new_max - base_min < minimum_deviation:
                # Adjust min value to maintain minimum deviation
                base_min = new_max - minimum_deviation
                if base_min < 0:
                    base_min = 0
                    new_max = minimum_deviation  # Adjust max too if needed
                
                # Update min handle position
                handle_2.global_position.x = value_to_position(base_min, handle_2)
            
            # Apply the new max value
            base_max = new_max
            
            handle_values.emit({"min": base_min, "max": base_max})
            set_instance_shader_parameter("left_percent", base_min)
            set_instance_shader_parameter("right_percent", base_max)

        if handle_2_active == true:
            var mouse_pos = get_global_mouse_position()
            var handle_width = handle_1.size.x * handle_1.scale.x
            var right_boundary = global_position.x+size.x - (handle_width/2)
            var left_boundary = global_position.x - (handle_width/2)
            handle_2.global_position.x = clamp(left_boundary, mouse_pos.x, right_boundary)
            
            # Calculate new base_min
            var new_min = lerp(0.0, 1.0, (handle_2.global_position.x - left_boundary)/(right_boundary-left_boundary))
            
            # Enforce minimum deviation
            if base_max - new_min < minimum_deviation:
                # Adjust max value to maintain minimum deviation
                base_max = new_min + minimum_deviation
                if base_max > 1.0:
                    base_max = 1.0
                    new_min = 1.0 - minimum_deviation  # Adjust min too if needed
                
                # Update max handle position
                handle_1.global_position.x = value_to_position(base_max, handle_1)
            
            # Apply the new min value
            base_min = new_min
            
            handle_values.emit({"min": base_min, "max": base_max})
            set_instance_shader_parameter("left_percent", base_min)
            set_instance_shader_parameter("right_percent", base_max)
            

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
# Also enforce minimum deviation in set_values
func set_values(_min_value: float = -1, _max_value: float = -1) -> void:
    if externally_overriden:
        return
        
    var updated = false
    
    # Check which values to update
    if _max_value >= 0:
        base_max = clamp(_max_value, 0.0, 1.0)
        updated = true
        
    if _min_value >= 0 and handle_2 != null:
        base_min = clamp(_min_value, 0.0, 1.0)
        updated = true
        
    # Ensure min doesn't exceed max and enforce minimum deviation
    if handle_2 != null:
        # First check if they're too close together
        if base_max - base_min < minimum_deviation:
            if _min_value >= 0 and _max_value < 0:
                # Min was explicitly set, adjust max
                base_max = base_min + minimum_deviation
                if base_max > 1.0:
                    base_max = 1.0
                    base_min = 1.0 - minimum_deviation
            elif _max_value >= 0 and _min_value < 0:
                # Max was explicitly set, adjust min
                base_min = base_max - minimum_deviation
                if base_min < 0:
                    base_min = 0
                    base_max = minimum_deviation
            else:
                # Both set or neither set, maintain center and apply minimum deviation
                var center = (base_min + base_max) / 2.0
                base_min = center - minimum_deviation/2
                base_max = center + minimum_deviation/2
                
                # Clamp values
                if base_min < 0:
                    base_min = 0
                    base_max = minimum_deviation
                if base_max > 1.0:
                    base_max = 1.0
                    base_min = 1.0 - minimum_deviation
        
        # Then ensure min <= max (this should be redundant after above check)
        if base_min > base_max:
            if _min_value >= 0:
                base_max = base_min
            else:
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
func set_max_value(_value: float) -> void:
    set_values(-1, _value)

func set_min_value(_value: float) -> void:
    print("set_min_value called with:", _value)
    set_values(_value, -1)



    
func set_handles_when_text_set():
    pass


func _on_line_edit_text_submitted(new_text: String) -> void:
    pass # Replace with function body.


var line_edit_last_value:String

func _on_line_edit_text_changed(new_text: String) -> void:
    #Only allow the user to submit numbers, like 1.0, 0.5, or 90. 
    #Divide by the mult value to set the internal value of the slider.
    #EG: 90 with a multi value of 100 becomes 0.9
    #If the user attempts to enter an invalid text, force the text to be line_edit_last_value.
    
    # Handle empty text case
    if new_text.is_empty():
        return
    
    # Check if the text is a valid number (allow decimal points and minus signs)
    var regex = RegEx.new()
    regex.compile("^-?\\d*\\.?\\d*$")
    var result = regex.search(new_text)
    
    if result and result.get_string() == new_text:
        # Valid number, save it as the last valid value
        line_edit_last_value = new_text
        
        # Try to convert the text to a float
        var value = float(new_text)
        
        # Convert to slider value (0-1 range) by dividing by mult_factor
        var slider_value = value / mult_factor
        slider_value = clamp(slider_value, 0.0, 1.0)
        
        # Update the slider without triggering recursive updates
        externally_overriden = true
        
        # Update the appropriate slider value (max for single handle, both for dual handle)
        if handle_2 == null:
            print("This situation shouldn't exist in a munition, actually. If you're seeing this you fucked up")
        else:
            var deviation = minimum_deviation/2
            print("DEVIATION WAR ", deviation)
            print("DAS MIN WAR ", slider_value - deviation)
            print("DAS MAX WAR ", slider_value + deviation)
            set_min_value(slider_value-deviation)
            set_max_value(slider_value+deviation)
        
        externally_overriden = false
    else:
        # Invalid input, revert to last valid value
        # Note: we need to defer this to avoid recursion issues
        if line_edit_last_value != null:
            # We call set_deferred on the LineEdit to restore the text
            # assuming the sender is a LineEdit control
            var line_edit = get_viewport().gui_get_focus_owner()
            if line_edit and line_edit is LineEdit:
                line_edit.call_deferred("set_text", line_edit_last_value)
