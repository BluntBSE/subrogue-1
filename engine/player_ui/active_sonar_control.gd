@tool
extends Control
class_name ActiveSonarControl

@export var angle_1 = 0.0
@export var angle_2 = 20.0
@export var a_diff:float

var inc = 0.0
func _process(delta: float) -> void:
    inc += delta * 50.0
    set_angle_1(inc)
    set_angle_2(45.0)
    a_diff = get_angle_diff(angle_1, angle_2)

func get_angle_diff(a1:float, a2:float)->float: #expecting degrees, not radians.
    var a1rad = deg_to_rad(a1)
    var a2rad = deg_to_rad(a2)
    var diff = angle_difference(a1rad, a2rad)
    var degdiff = rad_to_deg(diff)
    return degdiff

func set_angle_1(deg:float)->void:#Expects degree, not rad
    angle_1 = deg
    if angle_1 > 360.0:
        inc /= 360.0
        
    %ActiveSonarKnobOnePivot.rotation = deg_to_rad(angle_1)
    %ActiveSonarTexture.material.set_shader_parameter("start_angle", angle_1)
    %ActiveSonarBG.material.set_shader_parameter("start_angle", angle_1)
    
    

func set_angle_2(deg:float)->void:#Expects degree, not rad
    angle_2 = deg
    if angle_2 > 360.0:
        angle_2 /= 360.0
        
    %ActiveSonarKnobTwoPivot.rotation = deg_to_rad(angle_2)
    %ActiveSonarTexture.material.set_shader_parameter("end_angle", angle_2)
    %ActiveSonarBG.material.set_shader_parameter("end_angle", angle_2)
    
