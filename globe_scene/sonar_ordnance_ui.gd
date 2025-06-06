extends Control
class_name SonarOrdnanceUI

var state_machine:StateMachine
@onready var anim_player:AnimationPlayer = %SonarOrdnancePlayer
@onready var tab_node:Control = find_child("Tabs",true, false)
@onready var tabs:Array = tab_node.get_children()
var active_index:int = 0 # 0 = Active Sonar, 1 = Passive Sonar, 2 = Ordnance
var dark_2_color:Color = Color("#02282c")
var dark_1_color:Color = Color("#054349")
var dark_label:Color = Color("#b2b2b2")
var active_color:Color = Color("#a0a0a0")
var normal_outline:Color
var highlight_outline:Color
var highlight_color:Color = Color("#ffffff")
"""
02282c - Dark 2
054349 - Dark 1
b2b2b2 - Dark Label Modulate
a0a0a0 - Light modulate
"""
signal sonar_ordnance_ui_state

func _ready()->void:
    state_machine = StateMachine.new()
    state_machine.Add("ActiveSonarOpen", ActiveSonarOpenState.new(self,{}))
    state_machine.Add("PassiveSonarOpen", PassiveSonarOpenState.new(self,{}))
    state_machine.Add("OrdnanceOpen", OrdnanceOpenState.new(self,{}))
    #TransitioningState? Let's try to avoid it si podemos.
    state_machine.Change("ActiveSonarOpen", {})
    
    #We have some custom hover behavior that's easier to set up in code because we want self references
    for tab:TextureButton in tabs:
        tab.mouse_entered.connect(_on_tab_mouse_entered.bind(tab))
        tab.mouse_exited.connect(_on_tab_mouse_exit.bind(tab))
        
    adjust_tab_z()
    
    
func _process(delta:float)->void:
    #Probably not necessary yet.
    state_machine.stateUpdate(delta)


func _on_tab_mouse_entered(tab:TextureButton) -> void:
    tab.self_modulate = highlight_color
    var label:Label = tab.get_child(0)
    label.add_theme_color_override("font_outline_color", Color("#000000"))

    pass # Replace with function body.

func _on_tab_mouse_exit(tab:TextureButton)->void:
    #Tabs are colored by their index, so we need to remember the index of the active tab.
    #Could we have matched this on state machine value instead? Probably
    #But I wanted this pattern for bigger UI in the future
    var self_index:int = tabs.find(tab)
    var index_diff:int = abs(active_index - self_index)
    if index_diff == 0:
        tab.self_modulate = active_color
    if index_diff == 1:
        tab.self_modulate = dark_1_color
    if index_diff == 2:
        tab.self_modulate = dark_2_color
    var label:Label = tab.get_child(0)
    label.remove_theme_color_override("font_outline_color")
    
func adjust_tab_z() -> void:
    # Set the z_index for all tabs
    for index in range(tabs.size()):
        var tab = tabs[index]
        if index == active_index:
            # Active tab gets the highest z_index
            tab.z_index = tabs.size()
        else:
            # Other tabs are layered below the active tab
            tab.z_index = tabs.size() - index - 1
        #Feels silly with just 3, but this is how we get that depth switch on right vs left tabs.
        if active_index > (tabs.size()/2):
            tab.z_index = tabs.size() + index - 1
            
func adjust_tab_colors():
    for tab in tabs:
        var self_index:int = tabs.find(tab)
        var index_diff:int = abs(active_index - self_index)
        if index_diff == 0:
            tab.self_modulate = active_color
            tab.get_child(0).self_modulate = Color("#ffffff") #label
        if index_diff == 1:
            tab.self_modulate = dark_1_color
            tab.get_child(0).self_modulate = Color("#b2b2b2")
        if index_diff == 2:
            tab.self_modulate = dark_2_color
            tab.get_child(0).self_modulate = Color("#b2b2b2")

        var label:Label = tab.get_child(0)
        label.remove_theme_color_override("font_outline_color")

#3 is just enough to make you wonder if you should do this for a more general case. Whatever.
func _on_active_sonar_tab_button_up() -> void:
    if state_machine._current_state_id != "ActiveSonarOpen":
        state_machine.Change("ActiveSonarOpen", {})



func _on_passive_sonar_tab_button_up() -> void:
    if state_machine._current_state_id != "PassiveSonarOpen":
        state_machine.Change("PassiveSonarOpen", {})


func _on_ordnance_tab_button_up() -> void:
    if state_machine._current_state_id != "OrdnanceOpen":
        state_machine.Change("OrdnanceOpen", {})

func hide_sonar_ordnance_ui():
    #It feels like more work to write this in each SM than interrogate directly.
    var current_state = state_machine._current_state_id
    if current_state == "ActiveSonarOpen":
        %SonarOrdnancePlayer.play("ActiveSonarOut")
    if current_state == "PassiveSonarOpen":
        %SonarOrdnancePlayer.play("PassiveSonarOut")
    if current_state == "OrdnanceOpen":
        %SonarOrdnancePlayer.play("OrdnanceOut")


func show_sonar_ordnance_ui():
    #It feels like more work to write this in each SM than interrogate directly.
    var current_state = state_machine._current_state_id
    if current_state == "ActiveSonarOpen":
        %SonarOrdnancePlayer.play("ActiveSonarIn")
    if current_state == "PassiveSonarOpen":
        %SonarOrdnancePlayer.play("PassiveSonarIn")
    if current_state == "OrdnanceOpen":
        %SonarOrdnancePlayer.play("OrdnanceIn")
