extends Node
class_name GraphicsHelpers

static func set_custom_instance_shader_param(value:Variant, target:GeometryInstance3D, param_name:String):
    #Value comes first because of how binds work, which we exploit in tween method.
    #It annoys me too
    #Example usage:     var mt = tween.tween_method(set_custom_instance_shader_param.bind(%SonarPulseMeshNP, "frontier_head"), 0.0, maximum, 1.0)

    target.set_instance_shader_parameter(param_name, value)
        
