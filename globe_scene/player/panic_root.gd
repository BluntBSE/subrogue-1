extends Control

# Initialize with 6 hours in seconds (6 * 60 * 60)
var time_left = 21600  
@export var scroll_speed = 100.0  # Pixels per second

# Keep track of the original positions
var original_positions = {}

func _ready():
    #set_process(false)
    #visible = false
    # Store original positions of all children
    for child in %WarningContainer.get_children():
        original_positions[child] = child.position.x
        
    # Initial update
    update_warning_text()

func _process(delta: float):

    # Reduce time by 60x real world time
    time_left -= delta * 60
    
    # Don't let time go below zero
    if time_left < 0:
        time_left = 0
    
    # Update the warning text
    update_warning_text()
    
    # Scroll the warning container children
    scroll_warnings(delta)

func scroll_warnings(delta: float):
    var container_rect = %WarningContainer.get_rect()
    var container_width = container_rect.size.x
    
    for child in %WarningContainer.get_children():
        # Move the child to the left
        child.position.x -= scroll_speed * delta
        
        # If the child is completely off the left side, wrap it around
        if child.position.x < -child.size.x:
            child.position.x = container_width
            
        # Alternative approach: Reset to original position after going off-screen
        # if child.position.x < -child.size.x:
        #    child.position.x = original_positions[child]

func update_warning_text():
    # Format time as HH:MM:SS
    var hours = int(time_left / 3600)
    var minutes = int((time_left - hours * 3600) / 60)
    var seconds = int(time_left) % 60
    
    var time_string = "%02d:%02d:%02d" % [hours, minutes, seconds]
    var warning_string = "WARNING. CAPSIZE IMMINENT. DOCK WITHIN " + time_string
    
    # Update all labels in the warning container
    for child in %WarningContainer.get_children():
        if child is Label:
            child.text = warning_string
