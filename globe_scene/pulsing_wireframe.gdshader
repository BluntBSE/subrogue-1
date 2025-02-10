shader_type spatial;
render_mode unshaded, wireframe, cull_back;

uniform vec4 albedo : source_color = vec4(0.6, 0.3, 0.0, 1.0);
uniform float outline_width : hint_range(0.0, 10.0, 0.1) = 3.0;
uniform float tolerance : hint_range(0.0, 1.0, 0.01) = 0.5;
uniform float speed : hint_range(0.0, 10.0, 0.1) = 1.0;
uniform float dash_length : hint_range(0.0, 1.0, 0.01) = 0.1;

void vertex() {
    vec4 clip_position = PROJECTION_MATRIX * (MODELVIEW_MATRIX * vec4(VERTEX, 1.0));
    vec3 clip_normal = mat3(PROJECTION_MATRIX) * (mat3(MODELVIEW_MATRIX) * NORMAL);

    vec2 offset = normalize(clip_normal.xy) / VIEWPORT_SIZE *
        clip_position.w * outline_width * 2.0;

    clip_position.xy += offset;

    POSITION = clip_position;
}

void fragment() {
    float time_offset = TIME * speed;
    float dash_position = mod(UV.x - time_offset, dash_length * 2.0);

    if (dash_position < dash_length) {
        ALPHA = 1.0;
    } else {
        ALPHA = 0.0;
    }

    ALBEDO = albedo.rgb;
}