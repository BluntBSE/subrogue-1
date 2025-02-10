shader_type spatial;

uniform vec3 uAlbedo : source_color;
uniform sampler2D uTexureNormal;
uniform sampler2D uTexureNormal2;
uniform float uNormalMix: hint_range(0.0, 1.0, 0.2) = .2;
uniform vec2 uWaveDirection = vec2(1.0, 0.0);
uniform vec2 uWaveDirection2 = vec2(0.0, 1.0);
uniform float uTimeScale: hint_range(0.0, 0.2, 0.001) = 0.0015;
uniform float uWaveScale = 1.6;

void fragment() {
	vec2 time = (TIME * uWaveDirection) * uTimeScale;
	vec2 time2 = (TIME * uWaveDirection2) * uTimeScale;
	vec3 normal1 = texture(uTexureNormal, (UV * uWaveScale) + time).rgb;
	vec3 normal2 = texture(uTexureNormal2, UV * uWaveScale + time2).rgb;
	vec3 normal = mix(normal1, normal2, uNormalMix);

	ALBEDO = uAlbedo;
	METALLIC = .0;
	ROUGHNESS = .3;
	SPECULAR = 0.1;
	NORMAL_MAP = normal;
}
