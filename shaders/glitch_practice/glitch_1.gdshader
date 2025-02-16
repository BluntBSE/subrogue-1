shader_type canvas_item;
uniform int octave_count: hint_range(1, 20) = 10;
uniform float amp_start: hint_range(0.0, 10.0, 0.1) = 0.5;
uniform float amp_coeff: hint_range(0.0, 10.0, 0.1) = 0.5;
uniform float freq_coeff: hint_range(0.0, 10.0, 0.1) = 2.0;
uniform float shift_coeff: hint_range(0.0, 10.0, 0.1) = 1.0;
uniform float speed: hint_range(0.0, 10.0, 0.01) = 0.5;
//uniform sampler2D sprite_texture : source_color, filter_nearest; // set this in editor

vec2 hash22(vec2 uv){
    uv = vec2(
        dot(
            uv, vec2(127.1,311.7)
        ),
        dot(uv, vec2(269.5,183.3))
    );
    return 2.0 * fract(sin(uv) * 43758.5453123) - 1.0;
}

float noise(vec2 uv) {
vec2 iuv = floor(uv);
vec2 fuv = fract(uv);
vec2 blur = smoothstep(0.0, 1.0, fuv);
return mix(mix(dot(hash22(iuv + vec2(0.0,0.0)), fuv - vec2(0.0,0.0)),
dot(hash22(iuv + vec2(1.0,0.0)), fuv - vec2(1.0,0.0)),
blur.x),
mix(dot(hash22(iuv + vec2(0.0,1.0)), fuv - vec2(0.0,1.0)),
dot(hash22(iuv + vec2(1.0,1.0)), fuv - vec2(1.0,1.0)),
blur.x), blur.y) + 0.5;
}

float fbm(vec2 uv, int octaves) {
float value = 0.0;
float amplitude = amp_start;
for (int i = 0; i < octaves; i++) {
value += amplitude * noise(uv);
uv *= freq_coeff;
amplitude *= amp_coeff;
}
return value;
}

void vertex() {

}

void fragment() {
vec2 uv = UV;
float time = TIME * speed;
float shift = fbm(vec2(time), octave_count) * shift_coeff * 0.01;
float red = texture(TEXTURE, vec2(uv.x + shift, uv.y)).r;
float green = texture(TEXTURE, vec2(uv.x - shift, uv.y)).g;
float blue = texture(TEXTURE, vec2(uv.x, uv.y)).b;
COLOR = vec4(red, green, blue, 1.0);
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
