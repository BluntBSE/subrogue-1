/* Sprite3D outline shader (margins, billboard & regular) for Godot 4 by Sithoid
Sources used include: 2D Shader by fupi https://godotshaders.com/shader/outline-that-disrespects-boundaries/
Canvas outline by by luzzotica https://www.reddit.com/r/godot/comments/1220u8n/canvasgroup_outline_shader/
Explanations on 2D margins by Mathichai Dechdee https://forum.godotengine.org/t/solved-2d-shader-how-to-apply-a-margin-to-a-texture-before-applying-an-outline/5814/2
3d lifehacks by Anonzs https://www.reddit.com/r/godot/comments/11dklv0/sprite3d_shader/
Billboard projection by mrdunk https://ask.godotengine.org/152606/how-to-do-i-make-a-shader-a-billboard-face-the-player
Explanations on 3D transforms by Efi https://forum.godotengine.org/t/confused-about-uv-coordinate-transforms-in-3d/36903/2
Feel free to use AND correct, especially when it comes to unit conversion.
*/

shader_type spatial;
render_mode depth_draw_opaque, depth_prepass_alpha; //Settings needed to cast a shadow

// Overall settings
uniform bool enabled = true; // enable/disable
uniform sampler2D sprite_texture : source_color, filter_nearest; // set this in editor
uniform bool billboard = true; // switch modes

// Outline customization
//use rgb values > 1 to get HDR glow from a WorldEnvironment node
instance uniform vec4 color : source_color = vec4(3.0, 3.0, 0.0, 0.8); // outline rgba
uniform float line_thickness : hint_range(0.0, 20.0) = 15.0; //Works best under 10
uniform bool add_margins = true; // Still needs some natural margins but negates some cutoff

//12 directions for a smoother line; original used 8 with mn = mx = 0.71
const float mn = 0.5;
const float mx = 0.866;
const vec2 OFFSETS[12] = {
    vec2(0, 1), vec2(0, -1), vec2(1, 0), vec2(-1, 0),
    vec2(mn, mx),  vec2(mn, -mx), vec2 (-mn, mx), vec2 (-mn, -mx),
    vec2(mx, mn),  vec2(mx, -mn), vec2(-mx, mn), vec2(-mx,-mn)
};

void vertex() {
    vec2 texture_size = vec2(textureSize(sprite_texture,0));
    vec2 texture_pixel_size = 1.0 / texture_size;
    if (add_margins) {
        // Scale up the sprite
        VERTEX.xy += (UV * 2.0 - 1.0) * vec2(line_thickness, -line_thickness) * texture_pixel_size;
        //not sure if Y is inverted; kinda works with both but better with negative
    }

    if (billboard) {
        mat4 modified_model_view = VIEW_MATRIX * mat4(
            INV_VIEW_MATRIX[0],
            INV_VIEW_MATRIX[1],
            INV_VIEW_MATRIX[2],
            MODEL_MATRIX[3]
        );
        MODELVIEW_MATRIX = modified_model_view;
    }
}

void fragment() {
    // For drawing the regular sprite
    vec2 uv = UV;
    vec4 tex = texture(sprite_texture, uv);
    if (enabled) {
        //For drawing the initial scale
        vec2 texture_size = vec2(textureSize(sprite_texture,0));
        vec2 texture_pixel_size = 1.0 / texture_size;
        vec2 line_size = texture_pixel_size * line_thickness;
        if (add_margins) {
            // Scaling back down
            // Result of trial & error; normal formulas kept breaking
            // No idea what the last "line size" does and why there's no "2.0" for the second margin
            uv = (UV - line_size) * texture_size / (texture_size - line_size) + line_size;

            //Readjusting the texture after downscaling
            tex = texture(sprite_texture, uv);

            // This if is to remove artifacts outside the boundary of sprites
            // but it doesn't seem to do anything
            if (uv != clamp(uv, vec2(0.0), vec2(1.0))) {
                tex.a = 0.0;
            }
        }
        if (line_thickness >= 0.1) {
            float outline = 0.0;
            // Project in each direction, and add up the alpha of each projection.
            for (int i = 0; i < OFFSETS.length(); i++) {
                vec2 coordinate_offset = uv + line_size * OFFSETS[i];
                outline += texture(sprite_texture, coordinate_offset).a;
            }
            outline = min(outline, 1.0);
            tex = mix(tex, color, outline - ceil(tex.a)); //ceil(tex.a) to affect semi-transparent pixels
        }
    }
    ALBEDO = tex.rgb;
    ALPHA = tex.a;
}