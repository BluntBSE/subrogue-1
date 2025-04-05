shader_type spatial;
render_mode unshaded;
uniform sampler2D disc_texture;
uniform float start_angle; // 0 - 360
uniform float end_angle;   // 0 - 360
uniform float frontier_head; // Outer radius (0 - 1.0)
uniform float frontier_tail; // Inner radius (0 - 1.0)
uniform float outline_thickness; // Thickness of the outline (0.0 - 1.0)

void fragment() {
    // Base texture color
    ALBEDO = texture(disc_texture, UV).rgb;

    // Map UV coordinates to a normalized coordinate space (-1 to 1)
    vec2 cPos = -1.0 + 2.0 * UV;

    // Calculate the distance from the center
    float cdist = length(cPos);

    // Fade based on distance from the center
    float fade = 1.0 - cdist;
    ALPHA *= fade;

    // Calculate the angle of the current pixel in degrees
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

    // Check if the pixel is within the radial outline range
    bool within_outer_arc = cdist <= frontier_head && cdist >= (frontier_head - outline_thickness);
    bool within_inner_arc = cdist <= (frontier_tail + outline_thickness) && cdist >= frontier_tail;

    // Check if the pixel is within the angular outline range, clamped to the radial boundaries
    bool within_left_side = within_angle_range && cdist <= frontier_head && cdist >= frontier_tail && abs(angle - start_angle) <= outline_thickness * 360.0 / (2.0 * 3.14159 * cdist);
    bool within_right_side = within_angle_range && cdist <= frontier_head && cdist >= frontier_tail && abs(angle - end_angle) <= outline_thickness * 360.0 / (2.0 * 3.14159 * cdist);

    // Combine all conditions to create the hollow slice
    if ((within_outer_arc || within_inner_arc || within_left_side || within_right_side) && within_angle_range) {
        // Keep the outline visible
        ALPHA = 0.3;
    } else {
        // Make everything else transparent
        ALPHA = 0.0;
    }
}