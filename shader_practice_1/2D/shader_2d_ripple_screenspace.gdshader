// Converted/modified from ShaderToy: https://www.shadertoy.com/view/ldBXDD
// Attach this shader to a ColorRect
shader_type canvas_item;
uniform sampler2D SCREEN_TEXTURE: hint_screen_texture, filter_linear_mipmap;

uniform float wave_count : hint_range(1.0, 20.0, 1.0) = 20.0;
uniform float speed : hint_range(0.0, 10.0, 0.1) = 3.0;
uniform float height : hint_range(0.0, 0.1, 0.001) = 0.003;
uniform float exemption_radius: hint_range(0.0,1.0,0.001) = 0.0; //Expressed as a percent of the UV, which runs from 0 to 1. A value of .10 represents the radius of a circle from UV 0.45 to UV 0.55 in which the shader is NOT applied

void fragment() {
    //Make all positions relative to the middle by minusing -1 and adding 2
    vec2 cPos = -1.0 + 2.0 * UV;// * (1.0 / TEXTURE_PIXEL_SIZE); // 1.0 / Texture_pizel_ssize...optional?
    float cLength = length(cPos);

    vec2 uv = FRAGCOORD.xy / (1.0 / SCREEN_PIXEL_SIZE).xy;

    // Apply wave effect only if outside the exemption radius
    if (cLength > exemption_radius) {
        uv += (cPos / cLength) * cos(cLength * wave_count - TIME * speed) * height;
    }

    vec3 col = texture(SCREEN_TEXTURE, uv).xyz;
    COLOR = vec4(col, 1.0);
}