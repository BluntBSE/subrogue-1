shader_type spatial;
uniform sampler2D disc_texture;
uniform float start_angle; // 0 - 360
uniform float end_angle; // 0 - 360
uniform float frontier_head; // 0 - 1.0 (We tried 0.5. It's 1.0. Somewhat surprised
uniform float frontier_tail;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Called for every pixel the material is visible on.
    ALBEDO = texture(disc_texture, UV).rgb;
    //ALPHA = texture(disc_texture, UV).a;
    vec2 cPos = -1.0 + 2.0 * UV;
    float cdist = length(cPos);
    float fade = 1.0 - cdist;
    ALPHA *= fade;

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
    if (cdist < frontier_head){
        if (cdist>frontier_tail){
            ALPHA = ALPHA;
        }
    }

    if (cdist>frontier_head){
        ALPHA = 0.0;
    }
    if (cdist<frontier_tail){
        ALPHA = 0.0;
    }

    if (within_angle_range) {
        ALPHA = ALPHA*0.025;
    } else {
        ALPHA = 0.0;
    }

}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
