@tool
extends Control
class_name ActiveSonarControl

@export var angle_1 = 340.0
@export var angle_2 = 20.0
@export var a_diff: float
@onready var ping_button = %PingButton
@onready var volume_bar:DraggableTPB = %VolumeBar
var sonar_node:SonarNode


var knob_1_active: bool = false
var knob_2_active: bool = false

signal s_angle_1
signal s_angle_2
signal ping_requested  #Emits with angleA, angleB

var inc = 0.0


func _ready() -> void:
    pass


func unpack() -> void:
    #Just to get the sonar arms in the right spot
    set_angle_1(340.0)
    set_angle_2(20.0)


func _process(delta: float) -> void:
    update_knobs()
    a_diff = get_angle_diff(angle_1, angle_2)


func get_angle_diff(a1: float, a2: float) -> float:  #expecting degrees, not radians.
    var a1rad = deg_to_rad(a1)
    var a2rad = deg_to_rad(a2)
    var diff = angle_difference(a1rad, a2rad)
    var degdiff = rad_to_deg(diff)
    return degdiff


func set_angle_1(deg: float) -> void:  #Expects degree, not rad
    angle_1 = deg
    if angle_1 > 360.0:
        pass
        #inc /= 360.0 I dont think we need this.
    if angle_1 < 0:
        angle_1 += 360

    %ActiveSonarKnobOnePivot.rotation = deg_to_rad(angle_1)
    %ActiveSonarTexture.material.set_shader_parameter("start_angle", angle_1)
    %ActiveSonarBG.material.set_shader_parameter("start_angle", angle_1)
    s_angle_1.emit(angle_1)


func set_angle_2(deg: float) -> void:  #Expects degree, not rad
    angle_2 = deg
    if angle_2 > 360.0:
        pass
        #inc /= 360.0
    if angle_2 < 0:
        angle_2 += 360

    %ActiveSonarKnobTwoPivot.rotation = deg_to_rad(angle_2)
    %ActiveSonarTexture.material.set_shader_parameter("end_angle", angle_2)
    %ActiveSonarBG.material.set_shader_parameter("end_angle", angle_2)
    s_angle_2.emit(angle_2)


func handle_mouse_drag() -> void:
    pass


func _on_active_sonar_knob_one_pressed() -> void:
    print("Pressed! Setting knob 1 to active")
    knob_1_active = true

    pass  # Replace with function body.


func _on_active_sonar_knob_one_button_up() -> void:
    knob_1_active = false


func update_knobs() -> void:
    if knob_1_active == true:
        var mouse_pos: Vector2 = get_viewport().get_mouse_position()
        var up_vector = Vector2(0.0, -1.0)
        var mouse_angle = rad_to_deg(up_vector.angle_to(get_local_mouse_position()))
        set_angle_1(mouse_angle)

    if knob_2_active:
        var mouse_pos: Vector2 = get_viewport().get_mouse_position()
        var up_vector = Vector2(0.0, -1.0)
        var mouse_angle = rad_to_deg(up_vector.angle_to(get_local_mouse_position()))
        set_angle_2(mouse_angle)


func _on_active_sonar_knob_two_pressed() -> void:
    knob_2_active = true


func _on_active_sonar_knob_two_button_up() -> void:
    knob_2_active = false


func _on_ping_button_button_up() -> void:
    ping_requested.emit(angle_1, angle_2)
    SoundManager.play("sonar_1")
    pass  # Replace with function body.

func handle_external_angle_2(angle:float): #Given in degrees
    #Same as set angle 2 but without the emit
    angle_2 = angle
    if angle_2 > 360.0:
        pass
        #inc /= 360.0
    if angle_2 < 0:
        angle_2 += 360

    %ActiveSonarKnobTwoPivot.rotation = deg_to_rad(angle_2)
    %ActiveSonarTexture.material.set_shader_parameter("end_angle", angle_2)
    %ActiveSonarBG.material.set_shader_parameter("end_angle", angle_2)
    
func handle_external_angle_1(angle:float): #Given in degrees
    #Same as set angle 1 without the emit, and with a sanity check
    angle_1 = angle
    if angle_1 > 360.0:
        pass
        #inc /= 360.0 I dont think we need this.
    if angle_1 < 0:
        angle_1 += 360

    %ActiveSonarKnobOnePivot.rotation = deg_to_rad(angle_1)
    %ActiveSonarTexture.material.set_shader_parameter("start_angle", angle_1)
    %ActiveSonarBG.material.set_shader_parameter("start_angle", angle_1)


func handle_external_volume(vol:float):
    print("HEV RECEIVED ", vol)
    volume_bar.value = clamp(vol, 0.0, 1.0)
    pass
