shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_disabled, unshaded;
uniform sampler2D TEXTURE;
uniform vec4 rim_color : source_color = vec4(1.0, 1.0, 0.0, 1.0); // Default to yellow
uniform float rim_intensity : hint_range(0.0, 5.0) = 1.0; // Intensity of the rim effect

void fragment() {
    // Preserve the transparency of the previous pass
    vec4 base_color = texture(TEXTURE, UV);
    ALPHA = base_color.a; // Use the alpha from the previous texture

    // Calculate the rim effect
    float rim = 1.0 - max(0.0, dot(NORMAL, VIEW)); // Rim intensity based on view angle
    rim = pow(rim, rim_intensity); // Adjust rim intensity with a power function

    // Combine the rim color with the base color
    vec3 final_color = mix(base_color.rgb, rim_color.rgb, rim * rim_color.a);

    ALBEDO = final_color;
}