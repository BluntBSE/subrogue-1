shader_type spatial;

uniform vec4 pulse_color: source_color;
uniform sampler2D SCREEN_TEXTURE: hint_screen_texture, filter_linear_mipmap;
render_mode blend_mix;

uniform float wave_count : hint_range(1.0, 20.0, 1.0) = 20.0;
uniform float speed : hint_range(0.0, 10.0, 0.1) = 3.0;
uniform float height : hint_range(0.0, 0.1, 0.001) = 0.003;
uniform float exemption_radius: hint_range(0.0, 1.0, 0.001) = 0.0; // Expressed as a percent of the UV, which runs from 0 to 1. A value of .10 represents the radius of a circle from UV 0.45 to UV 0.55 in which the shader is NOT applied

uniform vec3 sphere_b_center; // Center of Sphere B
uniform float sphere_b_radius; // Radius of Sphere B

void fragment() {
    // Calculate the spherical coordinates for Sphere A
    vec3 world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
    vec3 center = vec3(0.0, 0.0, 0.0);
    float distance = length(world_pos - center);
    
    vec2 uv = FRAGCOORD.xy / VIEWPORT_SIZE.xy;
    
    float wave = 0.0;
    
    // Apply wave effect only if outside the exemption radius
    if (distance > exemption_radius) {
        wave = cos(distance * wave_count - TIME * speed) * height;
        uv += (world_pos.xy / distance) * wave;
    }
    
    vec3 col = texture(SCREEN_TEXTURE, uv).rgb;
    
    // Blend pulse_color based on the wave value
    float pulse_intensity = smoothstep(0.0, height, abs(wave));
    col = mix(col, pulse_color.rgb, pulse_intensity);
    
    // Project the effect onto Sphere B
    vec3 dir_to_b = normalize(sphere_b_center - world_pos);
    vec3 projected_pos = sphere_b_center + dir_to_b * sphere_b_radius;
    vec4 proj_coords = MODEL_MATRIX * vec4(projected_pos, 1.0);
    vec3 proj_uv = proj_coords.xyz / proj_coords.w;
    proj_uv = proj_uv * 0.5 + 0.5; // Transform from [-1, 1] to [0, 1]
    
    // Sample the render texture
    vec3 proj_col = texture(SCREEN_TEXTURE, proj_uv.xy).rgb;
    
    // Apply the sampled color to the fragment
    ALBEDO = mix(col, proj_col, pulse_intensity);
    EMISSION = col * pulse_intensity;
}