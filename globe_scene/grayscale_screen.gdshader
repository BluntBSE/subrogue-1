shader_type canvas_item;

uniform float flicker_intensity: hint_range(0.0, 1.0, 0.01) = 0.5; // Intensity of the flicker
uniform float flicker_speed: hint_range(0.0, 10.0, 0.1) = 2.0; // Speed of the flicker
uniform float pale_intensity: hint_range(0.0, 1.0, 0.01) = 0.5; // How pale the screen becomes
uniform sampler2D SCREEN_TEXTURE: hint_screen_texture, repeat_disable, filter_nearest;
uniform bool active = false;

float random(vec2 uv) {
    return fract(sin(dot(uv.xy, vec2(12.9898, 78.233))) * 43758.5453);
}

void fragment() {
    if (active == true) {
        vec2 uv = UV;

        // Sample the screen texture
        vec4 screen_color = texture(SCREEN_TEXTURE, uv);

        // Generate a flicker effect using time and UV coordinates
        float time = TIME * flicker_speed;
        float flicker = random(vec2(time, uv.x + uv.y)) * flicker_intensity;

        // Desaturate the screen color to make it paler
        float gray = dot(screen_color.rgb, vec3(0.299, 0.587, 0.114)); // Luminance formula
        vec3 pale_color = mix(screen_color.rgb, vec3(gray), pale_intensity);

        // Apply the flicker effect by modulating the brightness
        vec3 final_color = pale_color + flicker;

        // Clamp the final color to avoid over-brightening
        final_color = clamp(final_color, 0.0, 1.0);

        // Set the final color
        COLOR = vec4(final_color, screen_color.a);
    } else {
        // If not active, just pass through the screen texture
        COLOR = texture(SCREEN_TEXTURE, UV);
    }
}