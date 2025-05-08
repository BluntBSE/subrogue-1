extends Node3D
class_name WarningNode


func _process(_delta:float):

    scale_with_camera_distance()

func scale_with_camera_distance():
    #Base parameters: at 200 distance, scale of 1.0.
    #At 1000 distance, scale of 3.0
    var camera = get_viewport().get_camera_3d()
    var distance = camera.global_position - global_position
    var ratio = inverse_lerp(20, 200, distance.length())
    var sf = lerp(1.0,3.0, ratio)
    sf = clamp(sf, 0.2,2.5)
    scale = Vector3(sf,sf,sf)
