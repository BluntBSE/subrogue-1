shader_type spatial;
render_mode skip_vertex_transform;
render_mode unshaded, blend_mix; // Added blend_mix for transparency

#include "res://addons/godot-polyliner/shaders/include/polyliner_inc.gdshaderinc"

uniform float line_width = 0.03;
uniform sampler2D width_curve : source_color;
uniform bool tangent_facing = false;
uniform bool rounded = false;
uniform bool tube_normal = true;
uniform float alpha_override = 1.0;
uniform float fade_end_percent : hint_range(0.0, 1.0, 0.01) = 0.1; // Control fade length (10% default)

uniform bool uv_matches_width = true;
uniform vec2 tex_scale = vec2(1.0,1.0);

varying float is_end;
varying float v_line_length; // Added varying to pass line_length to fragment shader

void vertex(){
    VERTEX = (MODELVIEW_MATRIX * vec4(VERTEX,1.0)).xyz;

    NORMAL = mat3(MODELVIEW_MATRIX) * NORMAL;
    TANGENT = mat3(MODELVIEW_MATRIX) * TANGENT;
    BINORMAL = mat3(MODELVIEW_MATRIX) * BINORMAL;

    quick_line(line_width, rounded);

    if (uv_matches_width) { UV.x /= line_width; }

    UV.x = 1.0-UV.x;

    float line_length = UV2.x;
    v_line_length = line_length; // Store line_length for fragment shader
    UV2 = UV;
    UV2.x *= line_length;

    // correct the texture coordinates at the rounded ends
    if (rounded) {
        const float SQ2 = sqrt(2.0);
        float uv_correct = -is_end;

        if (uv_matches_width) { uv_correct *= line_width*SQ2; }
        else { uv_correct *= line_width/abs(tex_scale.x); }
        
        UV.x += uv_correct;
        UV2.x += uv_correct;
    }

    TANGENT =  TANGENT * mat3(MODELVIEW_MATRIX);
    BINORMAL = BINORMAL * mat3(MODELVIEW_MATRIX);
}

uniform sampler2D texture_alb : hint_default_white, source_color;
uniform sampler2D texture_rgh : hint_default_white;
uniform bool tex_stretch = true;

uniform vec4 color : source_color = vec4(vec3(1.0),1.0);
uniform float metallic  : hint_range(0.0,1.0,0.005) = 0.0;
uniform float specular  : hint_range(0.0,1.0,0.005) = 0.5;
uniform float roughness : hint_range(0.0,1.0,0.005) = 0.5;

void fragment() {
    if (!FRONT_FACING) { NORMAL = -NORMAL; }

    if (tube_normal && !tangent_facing) {
        NORMAL_MAP = getLineTubeNormal(UV,is_end,rounded);
    }

    if (rounded && abs(is_end) > 0.0001) {
        float softner = magic_aa(6000.0,VERTEX,VIEWPORT_SIZE);
        softner *= (1.0/line_width) * (min(abs(is_end)*2.0,1.0));
        ALPHA *= smoothstep(1.0,1.0+softner,getDistToLineCenter(UV,is_end));
    }

    vec2 uv_alb = UV2;
    if (tex_stretch) {
        uv_alb = UV;
    }
    uv_alb *= tex_scale;
    uv_alb = uv_alb.yx; // more intuitive

    vec4 alb_sample = texture(texture_alb,uv_alb.yx);
    vec4 rgh_sample = texture(texture_rgh,uv_alb.yx);

    ALBEDO = alb_sample.rgb * alb_sample.a * color.rgb;
    SPECULAR = specular;
    ROUGHNESS = roughness * rgh_sample.r;
    METALLIC = metallic;
    
    // Calculate position along line from UV2.x
    // Since UV2.x was multiplied by line_length, we need to divide by v_line_length to normalize it
    float line_position = UV2.x / v_line_length;
    
    // Fade out over the last fade_end_percent portion of the line
    // 1.0 at (1.0 - fade_end_percent) position, 0.0 at end of line
    float fade_factor = 1.0 - smoothstep(1.0 - fade_end_percent, 1.0, line_position);
    
    // Apply the fade to alpha
    ALPHA = alpha_override * fade_factor;
}