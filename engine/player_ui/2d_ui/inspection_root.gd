extends Node
class_name InspectionRoot

###SIGNAL INSPECTION
#We're doing this in a higher level node instead of giving the panels their own code because
#We also have signals that toggle visibility in mutually dependent ways
#Bigger file, but easier debugging I think?
var inspecting_signal:SignalPopup
var inspecting_entity:Entity #Positively ID'd
signal closed_unidentified
signal closed_identified
signal edited_signal_name
signal edited_signal_type
signal edited_color

#Unidentified open
func handle_opened_signal(sig:SignalPopup):
    if inspecting_signal:
        disconnect_unidentified(inspecting_signal)

    inspecting_signal = sig
    #Close Entity inspection if it's open
    if %EntityInspection.visible == true:
        %EntityInspection.get_node("AnimationPlayer").play_backwards("slide_in")
        await %EntityInspection.get_node("AnimationPlayer").animation_finished
        %EntityInspection.visible = false
        closed_identified.emit()

    %SignalIDInput.text = sig.signal_id
    %SignalInspection.visible  = true
    var player:AnimationPlayer = %SignalInspection.get_node("AnimationPlayer")
    player.play("slide_in")
    #The second you open, recalculate stuff like size, etc. Forces an update.
    sig.stream.emit({"volume":sig.sound.volume, "pitch":sig.sound.pitch, "certainty":sig.certainty, "entity": sig.detected_object})

    handle_color_stream(sig.color)
    connect_unidentified(sig)

#Identified open
func handle_openened_identified_signal(sig:SignalPopup):
    inspecting_signal = sig
    %SignalInspection.visible = false
    %EntityInspection.visible = true
    load_inspected_entity(sig.detected_object)
    var player:AnimationPlayer = %EntityInspection.get_node("AnimationPlayer")
    player.play("slide_in")

func handle_identified_signal(sig:SignalPopup):
    #If this is the signal you were already looking at, and it's positive now,
    #Close signal inspector and open the more detailed entity inspector
    if sig == inspecting_signal and %SignalInspection.visible == true:
        var player:AnimationPlayer = %SignalInspection.get_node("AnimationPlayer")
        player.play_backwards("slide_in")
        load_inspected_entity(sig.detected_object)
        await player.animation_finished
        %SignalInspection.visible = false
        %EntityInspection.visible = true
        player = %EntityInspection.get_node("AnimationPlayer")
        player.play("slide_in")
    #No matter what, positively identified signals no longer respond to the panel    
    disconnect_unidentified(sig)

func _on_signal_inspector_toggle_button_up() -> void:
    var player:AnimationPlayer = %SignalInspection.get_node("AnimationPlayer")
    player.play_backwards("slide_in")
    await player.animation_finished
    %SignalInspection.visible = false


    pass # Replace with function body.

func handle_SI_stream(dict:Dictionary):#{"volume":x, "certainty":x, "pitch":x, "entity": x}
    %SignalPitch.text = "Pitch: " + str(dict.pitch)
    %SignalCertainty.text = "Certainty: "+str(dict.certainty)
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
    #We do this as opposed to updating directly from the color picker because there might be events that cause signal objects to change their own color
    #And we want to update the player accordingly
    #E.G: Faction identification, if not perfect identification.
    var spike_mesh:MeshInstance3D = %SpikyBoy.get_node("MeshInstance3D")
    var shader_color:Vector3 = Vector3(color.r,color.g,color.b)
    spike_mesh.material_override.set("shader_parameter/color", shader_color)
    %SignalColorChanger.modulate = color
    #Positively identified:
    var ship_mesh:MeshInstance3D = find_child("Ship3DRoot", true, false).get_child(0)#The first child of this root should always be a ship mesh.
    #Probably we'll switch out scenes for every ship type and attach them directly to Ship3D root.
    #These scenes will be defined on the entity resource itself
    ship_mesh.material_override.set("shader_parameter/albedo", shader_color)
    %EntityName.add_theme_color_override("font_outline_color", color)
    %EntityFaction.add_theme_color_override("font_outline_color", color)
    %EntityClass.add_theme_color_override("font_outline_color", color)


func _on_entity_inspector_toggle_button_up() -> void:
    var player:AnimationPlayer = %EntityInspection.get_node("AnimationPlayer")
    player.play_backwards("slide_in")
    await player.animation_finished
    %EntityInspection.visible = false
    closed_identified.emit()
    pass # Replace with function body.


func load_inspected_entity(entity:Entity):
    if inspecting_entity:
        closed_identified.disconnect(entity.render.handle_release_observed)
    %EntityName.text = entity.given_name
    %EntitySize.text = "Size: " + str(entity.atts.size)+"m³"
    %EntityClass.text = entity.atts.class_display_name
    %EntitySpeed.text = "Max speed: " + str(GlobeHelpers.game_s_to_kph(entity.max_speed))
    %EntityPitch.text = "Pitch: " +str(entity.emission.pitch)
    %EntityProfile.text = "Profile: " + str(entity.emission.profile)
    %EntityVolume.text = "Volume: " + str(entity.emission.volume)
    %EntityDepth.text = "Depth: " + str(entity.atts.current_depth)
    #closed_identified.connect(entity.render.handle_release_observed)
    


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
    %SignalInspection.visible = false
    %EntityInspection.visible = true
    load_inspected_entity(entity)
    var player:AnimationPlayer = %EntityInspection.get_node("AnimationPlayer")
    player.play("slide_in")
