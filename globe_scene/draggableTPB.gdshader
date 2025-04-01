shader_type canvas_item;

// Uniforms for textures
uniform sampler2D texture_progress;
uniform sampler2D texture_under;

// Uniforms for tints
instance uniform vec4 tint_progress : source_color;
uniform vec4 tint_under : source_color;

// Uniforms for handle positions
instance uniform float left_percent : hint_range(0.0, 1.0);
instance uniform float right_percent : hint_range(0.0, 1.0);

void fragment() {
    vec2 uv = UV;

    // Determine which part of the texture to render
    if (uv.x < left_percent) {
        // Render the "under" texture with its tint
        COLOR = texture(texture_under, uv) * tint_under;
    } else if (uv.x > right_percent) {
        // Render the "under" texture with its tint (for the "over" region)
        COLOR = texture(texture_under, uv) * tint_under;
    } else {
        // Render the "progress" texture with its tint
        COLOR = texture(texture_progress, uv) * tint_progress;
    }
}