shader_type canvas_item;

uniform sampler2D disc_texture;
uniform float start_angle : hint_range(0.0, 360.0); // Start angle in degrees
uniform float end_angle : hint_range(0.0, 360.0);   // End angle in degrees
uniform float frontier_head : hint_range(0.0, 1.0) = 1.0; // Outer radius (normalized)
uniform float frontier_tail : hint_range(0.0, 1.0) = 0.5; // Inner radius (normalized)

void fragment() {
    // Get the texture color
    vec4 tex_color = texture(disc_texture, UV);
    vec2 cPos = UV * 2.0 - vec2(1.0); // Convert UV to range [-1, 1]
    float cdist = length(cPos);       // Distance from the center
    float fade = 1.0 - cdist;         // Fading effect based on distance

    // Calculate the angle of the current fragment in degrees
    float angle = degrees(atan(cPos.y, cPos.x));
    if (angle < 0.0) {
        angle += 360.0; // Ensure angle is in the range [0, 360]
    }

    // Check if the angle is within the specified range
    bool within_angle_range = false;
    if (start_angle < end_angle) {
        within_angle_range = angle >= start_angle && angle <= end_angle;
    } else {
        within_angle_range = angle >= start_angle || angle <= end_angle;
    }

    // Check if the distance is within the frontier limits
    bool within_frontier_limits = cdist >= frontier_tail && cdist <= frontier_head;

    // Determine the alpha value
    float alpha = tex_color.a * fade; // Base alpha with fade effect
    if (!within_angle_range || !within_frontier_limits) {
        alpha = 0.0; // Hide if outside angle or distance range
    }

    // Set the final color
    COLOR.rgb = tex_color.rgb;
    COLOR.a = alpha;
}