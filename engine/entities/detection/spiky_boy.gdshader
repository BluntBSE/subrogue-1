shader_type spatial;
render_mode unshaded;
render_mode wireframe;
uniform vec3 color: source_color;

float hash(vec2 p) {
    return fract(sin(dot(p * 17.17, vec2(14.91, 67.31))) * 4791.9511);
}

void vertex() {
    // Use the normal vector's components to calculate a consistent displacement
    float displacement = cos(NORMAL.x * 4.0 * TIME) * sin(NORMAL.y * 4.0 * TIME);

    // Displace the vertex along its normal
    VERTEX += NORMAL * displacement * 0.2; // Adjust the multiplier for stronger/weaker displacement
}

void fragment() {
    // Optional: Add color or other effects in the fragment shader
    ALBEDO = color; // White color
}