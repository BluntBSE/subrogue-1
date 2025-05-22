shader_type spatial;

uniform sampler2D disc_texture;
instance uniform float start_angle; // 0 - 360
instance uniform float end_angle; // 0 - 360
instance uniform float frontier_headn; // 0 - 1.0 (We tried 0.5. It's 1.0. Somewhat surprised
instance uniform float frontier_tailn;
uniform vec3 modulate: source_color;

void vertex() {
    // Called for every vertex the material is visible on.
}

void fragment() {
    // Called for every pixel the material is visible on.
    vec4 tex_color = texture(disc_texture, UV);

    // Apply modulate color to the texture
    ALBEDO = tex_color.rgb * modulate;

    vec2 cPos = -1.0 + 2.0 * UV;
    float cdist = length(cPos);
    float fade = 1.0 - cdist;
    ALPHA = tex_color.a * fade;

    // Calculate the angle of a given in degrees relative to the center
    float angle = degrees(atan(cPos.y, cPos.x));
    if (angle < 0.0) {
        angle += 360.0;
    }

    // Check if the angle is within the specified range
    bool within_angle_range = false;
    if (start_angle < end_angle) {
        within_angle_range = angle >= start_angle && angle <= end_angle;
    } else {
        within_angle_range = angle >= start_angle || angle <= end_angle;
    }

    bool within_frontier_limits=false;
    if (cdist < frontier_headn){
        if (cdist>frontier_tailn){
            ALPHA = ALPHA;
        }
    }

    if (cdist>frontier_headn){
        ALPHA = 0.0;
    }
    if (cdist<frontier_tailn){
        ALPHA = 0.0;
    }

    if (within_angle_range) {
        ALPHA = ALPHA;
    } else {
        ALPHA = 0.0;
    }
}

//void light() {
    // Called for every pixel for every light affecting the material.
    // Uncomment to replace the default light processing function with this one.
//}