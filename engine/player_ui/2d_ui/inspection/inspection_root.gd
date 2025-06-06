extends Node
class_name InspectionRoot

###SIGNAL INSPECTION
#We're doing this in a higher level node instead of giving the panels their own code because
#We also have signals that toggle visibility in mutually dependent ways
#Bigger file, but easier debugging I think?
var inspecting_signal:SignalPopup
var inspecting_entity:Entity #Positively ID'd
var active_inspection_color:Color
var state_machine:StateMachine
@onready var signal_inspector_panel = %SignalInspection
@onready var entity_inspector_panel = %EntityInspection
@onready var signal_id_input = %SignalIDInput
@onready var entity_player:AnimationPlayer = %EntityInspection.get_node("AnimationPlayer")
@onready var signal_player:AnimationPlayer = %SignalInspection.get_node("AnimationPlayer")
signal closed_unidentified
signal closed_identified
signal edited_signal_name
signal edited_signal_type
signal edited_color

func _ready():
    state_machine = StateMachine.new()
    state_machine.Add("InspectorClosedState", InspectorClosedState.new(self,{}))
    state_machine.Add("InspectingUnidentifiedState", InspectingUnidentifiedState.new(self, {}))
    state_machine.Add("InspectingIdentifiedState", InspectingIdentifiedState.new(self,{}))
    state_machine.Add("InspectingSelfState", InspectingSelfState.new(self,{}))

#Unidentified open
func handle_opened_signal(sig:SignalPopup):
    if inspecting_signal:
        disconnect_unidentified(inspecting_signal)
        
    SoundManager.play_straight("ui_swoop_1", "ui")

    inspecting_signal = sig
    state_machine.Change("InspectingUnidentifiedState", {"signal":sig})

    handle_color_stream(sig.color)
    connect_unidentified(sig)

#Identified open
func handle_opened_identified_signal(sig:SignalPopup):
    print("Fired handle_opened state")
    inspecting_signal = sig
    state_machine.Change("InspectingIdentifiedState", {"signal":inspecting_signal})

func handle_identified_signal(sig:SignalPopup):
    #If this is the signal you were already looking at, and it's positive now,
    #Close signal inspector and open the more detailed entity inspector
    if sig == inspecting_signal:
        state_machine.Change("InspectingIdentifiedState", {"signal":sig})
    #No matter what, positively identified signals no longer respond to the panel    
    disconnect_unidentified(sig)

func _on_signal_inspector_toggle_button_up() -> void:
    state_machine.Change("InspectorClosedState", {})


func handle_SI_stream(dict:Dictionary):#{"volume":x, "certainty":x, "pitch":x, "entity": x}
    %SignalPitch.text = "Pitch: " + str(dict.pitch)
    %SignalCertainty.text = "Certainty: "+str(snapped(dict.certainty, 0.1))
    var _entity:Entity = dict.entity
    randomize()
    %SignalSize.text = "Size: " + str(SignalHelpers.get_uncertain_size(dict.entity.atts.size, dict.certainty))
    %SignalVolume.text = "Volume: " + str(dict.volume)+"db"
    pass


func _on_signal_id_input_text_changed(new_text: String) -> void:
    edited_signal_name.emit(new_text)
    pass # Replace with function body.


func _on_signal_color_changer_color_changed(color: Color) -> void:
    edited_color.emit(color)
    pass # Replace with function body.

func handle_color_stream(color:Color)->void:
    active_inspection_color = color
    print("Active inspection color set to ", active_inspection_color)
    #We do this as opposed to updating directly from the color picker because there might be events that cause signal objects to change their own color
    #And we want to update the player accordingly
    #E.G: Faction identification, if not perfect identification.
    var spike_mesh:MeshInstance3D = %SpikyBoy.get_node("MeshInstance3D")
    var shader_color:Vector3 = Vector3(color.r,color.g,color.b)
    spike_mesh.material_override.set("shader_parameter/color", shader_color)
    %SignalColorChanger.modulate = color
    #Positively identified:
    update_ship_colors(color)
    
func update_ship_colors(color:Color):
    var shader_color = Vector3(color.r,color.g,color.b)
    var ship_mesh:MeshInstance3D = find_child("Ship3DRoot", true, false).get_child(0)#The first child of this root should always be a ship mesh.
    #Probably we'll switch out scenes for every ship type and attach them directly to Ship3D root.
    #These scenes will be defined on the entity resource itself
    ship_mesh.material_override.set("shader_parameter/albedo", shader_color)
    %EntityName.add_theme_color_override("font_outline_color", color)
    %EntityFaction.add_theme_color_override("font_outline_color", color)
    %EntityClass.add_theme_color_override("font_outline_color", color)

func _on_entity_inspector_toggle_button_up() -> void:
    state_machine.Change("InspectorClosedState", {})
    #closed_identified.emit() - 
    pass # Replace with function body.


func load_inspected_entity(entity:Entity):
    if inspecting_entity:
        #This is what prevents actions from taking place on things you already have selected,
        #Even though we didn't implement the observer pattern more broadly.
        closed_identified.disconnect(entity.render.handle_release_observed)
    %EntityName.text = entity.given_name
    %EntityFaction.text = entity.faction.display_name
    %EntitySize.text = "Size: " + str(entity.atts.size)+"m³"
    %EntityClass.text = entity.atts.class_display_name
    %EntitySpeed.text = "Max speed: " + str(GlobeHelpers.game_s_to_kph(entity.max_speed))
    %EntityPitch.text = "Pitch: " +str(entity.emission.pitch)
    %EntityProfile.text = "Profile: " + str(entity.emission.profile)
    %EntityVolume.text = "Volume: " + str(entity.emission.volume)
    %EntityDepth.text = "Depth: " + str(entity.atts.current_depth)
    var inspection_scene:InspectionScene3D = %ShipPreviewSubViewport.get_child(0)
    print("Current inspection scene has ID of: ", inspection_scene.id)
    print("ENTITY id is ", entity.atts.type.id)
    if inspection_scene.id != entity.atts.type.id:
        var new_scene = entity.atts.type.inspection_scene.instantiate()
        inspection_scene.free()
        %ShipPreviewSubViewport.add_child(new_scene)
        update_ship_colors(active_inspection_color)
    closed_identified.connect(entity.render.handle_release_observed)
    


func connect_unidentified(sig:SignalPopup):
    #sig.stream_color.connect(handle_color_stream) This connection is actually managed by the signalobject because it needs to be set up right away
    sig.stream.connect(handle_SI_stream)
    edited_color.connect(sig.handle_update_color)
    edited_signal_name.connect(sig.handle_update_name)
    #closed_unidentified.connect(sig.detected_object.render.handle_release_observed)

func disconnect_unidentified(sig:SignalPopup):
    #May have been destroyed before this, so we check if it exists at all.
    if sig:
        #We occasionally use this to just clear any connections for a clean slate. The check below is just for error quieting.
        if sig.stream_color.is_connected(handle_color_stream):
            sig.stream_color.disconnect(handle_color_stream)
        if sig.stream_color.is_connected(handle_color_stream):  
            sig.stream.disconnect(handle_SI_stream)
        if edited_color.is_connected(sig.handle_update_color):
            edited_color.disconnect(sig.handle_update_color)
        if edited_signal_name.is_connected(sig.handle_update_name):
            edited_signal_name.disconnect(sig.handle_update_name)
       # closed_unidentified.disconnect(sig.detected_object.render.handle_release_observed)


#For when you click on something you can actually 'see' (no longer a signal)
func handle_openened_identified_entity(entity:Entity):
    state_machine.Change("InspectingIdentifiedState", {"signal":inspecting_signal})
