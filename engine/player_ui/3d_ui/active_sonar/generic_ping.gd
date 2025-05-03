extends Node3D
class_name GenericPing
#used when we want to create pinglike visual effects that aren't necessarily part of the active sonar ping
#that players use
@export var material_1:ShaderMaterial
@export var material_2:ShaderMaterial
@export var cone_width:float = 40.0 #degrees
#Used to control other interactions we want tied to this if we expand it.
#For now, sounds are goinmg straight into send_pulse() since its only used for enemies
signal shadow_cast
signal shadow_finished
signal fill_cast
signal fill_finished #This is usually what we'll connect abberation etc. to.
signal finished

var angle_to:float: #Degrees
    set(value):
        angle_to = value
        var offset_down = angle_to - (cone_width/2)
        var offset_up = angle_to + (cone_width/2)
        #For some reason I can't seem to do the shader parameter stuff when I set the materials as variables and access them that way.
        %SonarPulseMesh.material_override.set_shader_parameter("start_angle", offset_down)
        %SonarPulseMesh.material_override.set_shader_parameter("end_angle", offset_up)
        %SonarPulseMesh.material_override.next_pass.set_shader_parameter("start_angle", offset_down)
        %SonarPulseMesh.material_override.next_pass.set_shader_parameter("end_angle", offset_up)


 
       

func send_pulse():
    #At the moment the only use case we have for the generic pings is hostile pings, which must first project their material
    #Before filling it in with the second part
    #PROJECT SHADOW
    var tween_time = 2.0
    SoundManager.play_straight("enemy_ping_direct_1")
    %SonarPulseMesh.material_override.set_shader_parameter("frontier_head", 0.0)
    %SonarPulseMesh.material_override.set_shader_parameter("frontier_tail", 0.0)
    var tween:Tween = get_tree().create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EaseType.EASE_OUT)
    tween.tween_property(%SonarPulseMesh, "material_override:shader_parameter/frontier_head", 1.0, tween_time).from_current()
    await tween.finished
    print("Shadow cast")
    #PROJECT FILL
    %SonarPulseMesh.material_override.next_pass.set_shader_parameter("frontier_head", 0.0)
    %SonarPulseMesh.material_override.next_pass.set_shader_parameter("frontier_tail", 0.0)
    var maximum = %SonarPulseMesh.material_override.get_shader_parameter("frontier_head") #How far the shadow got cast out
    var tween_2:Tween = get_tree().create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EaseType.EASE_OUT)
    tween_2.tween_property(%SonarPulseMesh, "material_override:next_pass:shader_parameter/frontier_head", maximum, 1.0).from_current()
    tween_2.set_trans(Tween.TRANS_CIRC)
    tween_2.tween_property(%SonarPulseMesh, "material_override:next_pass:shader_parameter/frontier_tail", maximum, 0.5).from_current()
    await tween_2.finished
    var tween_3:Tween = get_tree().create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EaseType.EASE_OUT)
    tween_3.set_trans(Tween.TRANS_CIRC)
    tween_3.tween_property(%SonarPulseMesh, "material_override:shader_parameter/frontier_head", 0.0, tween_time)
    await tween_3.finished
    finished.emit()
    #WHO DID YOU PING?
    

func aim_ping_at(from:Vector3, to:Vector3, from_axis:Vector3)->float:
    var local_basis = GlobeHelpers.get_aligned_basis(from_axis)
    var angle = GlobeHelpers.get_local_angle_between(to, from, from_axis) 
    return angle
    
func ping(from:Vector3, to:Vector3, from_axis:Vector3, width:float = 40.0):
    angle_to = aim_ping_at(from, to, from_axis)
    #adjust_volume()
    send_pulse()
