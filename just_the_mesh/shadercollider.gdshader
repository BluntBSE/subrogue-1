shader_type spatial;
uniform sampler2D heightmap;
uniform float height_ratio = 30.0;

void vertex() {
	// Called for every vertex the material is visible on.
    float height = texture(heightmap, UV).a * height_ratio;
    VERTEX += NORMAL * height;
    //float a = texture(heightmap,UV).a;
    //COLOR.a = 0.0;
}

void fragment() {

	// Called for every pixel the material is visible on.
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
