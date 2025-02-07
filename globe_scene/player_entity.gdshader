shader_type spatial;
render_mode blend_mix;

uniform sampler2D SCREEN_TEXTURE: hint_screen_texture, filter_linear;
uniform sampler2D TEXTURE; // Declare the texture uniform
uniform float Frequency = 1.0;
uniform float MaxOpacity : hint_range(0, 1) = 1.0;
uniform float MinimumOpacity : hint_range(.5, 1) = 0.0;

void fragment() {
    vec4 tex_color = texture(SCREEN_TEXTURE, UV); 

    float base_alpha = tex_color.a; // Use the texture's alpha channel.
    float time_based_factor = sin(Frequency * TIME);

    // Ensure opacity stays within the defined range
    float opacity_range = (1.0 - time_based_factor) * MinimumOpacity;
    float final_opacity = fma(time_based_factor, MaxOpacity, opacity_range);

    ALBEDO = tex_color.rgb; // Use texture color for the mesh
    ALPHA = base_alpha * final_opacity; // Adjust opacity dynamically
}
