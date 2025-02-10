shader_type spatial;

render_mode unshaded, blend_add, depth_draw_opaque;

uniform sampler2D texture_albedo : source_color, filter_linear_mipmap, repeat_enable;
uniform vec4 glow_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float glow_intensity : hint_range(0.0, 100.0) = 1.0;

void fragment() {
    vec4 tex_color = texture(texture_albedo, UV);

    
    // Apply the falloff to the alpha channel
    float alpha = tex_color.a;
    
    // Preserve the alpha channel for transparency
    ALBEDO = tex_color.rgb * glow_color.rgb * glow_intensity;
    ALPHA = alpha;
    
    // Additive blending for the glow effect
    EMISSION = tex_color.rgb * glow_color.rgb * glow_intensity * (1.0);
}