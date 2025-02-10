shader_type spatial;

render_mode unshaded, blend_add;

uniform sampler2D land_mask : source_color, filter_linear_mipmap, repeat_disable;

void fragment() {
    // Sample the texture
    vec4 tex_color = texture(land_mask, UV);

    // Set the albedo color to the RGB values of the texture
    ALBEDO = tex_color.rgb;

    // Set the alpha value to the alpha channel of the texture
    ALPHA = tex_color.a;
}