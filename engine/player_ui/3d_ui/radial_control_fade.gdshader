shader_type canvas_item;
uniform sampler2D disc_texture;
render_mode unshaded;
uniform float start_angle; // 0 - 360
uniform float end_angle; // 0 - 360

uniform float between_angle_alpha;
uniform float beyond_angle_alpha;

uniform float distance_factor : hint_range(0.0, 10.0, 0.01);

void vertex() {
    // Called for every vertex the material is visible on.
}

void fragment() {
    // Called for every pixel the material is visible on.
    COLOR.rgb = texture(disc_texture, UV).rgb;
    vec2 cPos = -1.0 + 2.0 * UV;
    float cdist = length(cPos);
    float fade = cdist * distance_factor;
    COLOR.a -= fade;
    
    // Calculate the angle of a given in degrees relative to the center
    //Angle towards the top of the screen
    float angle = degrees(atan(cPos.y, cPos.x)) + 90.0;
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
    
    if (within_angle_range) {
        COLOR.a *= between_angle_alpha;
    } else {
        COLOR.a *= beyond_angle_alpha;
    }
}