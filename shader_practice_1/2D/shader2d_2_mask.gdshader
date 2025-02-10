shader_type canvas_item;

uniform vec4 albedo : source_color;
uniform sampler2D texture_mask : source_color, filter_linear_mipmap, repeat_enable;

void vertex(){

}

void fragment(){
    vec4 tex_color = texture(TEXTURE, UV);
    float mult = UV.r * 2.0; //UV.r - horizontal gradient. UV.g, vertical gradient
    tex_color = tex_color * (albedo * mult);
    COLOR = tex_color;
}