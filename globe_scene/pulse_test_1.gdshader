shader_type spatial;
render_mode unshaded;

uniform vec3 unit_position;
uniform float ring_radius = 1.0;
uniform float ring_width = 0.1;

void fragment() {
    vec3 world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}