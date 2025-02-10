shader_type canvas_item;
uniform vec4 albedo : source_color;
uniform vec2 tiling = vec2(1.0, 1.0);
uniform vec2 offset;
uniform sampler2D texture_albedo : source_color, filter_linear_mipmap, repeat_enable;

void vertex() {
    // Called for every vertex the material is visible on.
    UV = (UV * tiling) + (offset * TIME );
}

void fragment() {
    // Called for every pixel the material is visible on.
    vec4 tex_color = texture(texture_albedo, UV);
    COLOR = tex_color * albedo;
}