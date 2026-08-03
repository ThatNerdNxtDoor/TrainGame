shader_type spatial;

uniform vec3 color_tint : source_color = vec3(1, 1, 1);

uniform sampler2D tex : filter_nearest;

const float light_quant = 20.0;

float backwards_square(float x) {
	float inv_x = 1.0-x;
	return 1.0 - inv_x * inv_x;
}

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Called for every pixel the material is visible on.
	
	ALBEDO = COLOR.rgb * texture(tex, UV).rgb * color_tint;
}

void light () {
	float angle_dot = clamp(dot(NORMAL, LIGHT), 0, 1);
	float strength[] = {0.0, 0.25, 0.6, 1.0};
	const int n = 4;
	float light_strength = (strength[clamp(int(backwards_square(angle_dot) * float(n)), 0, n-1)] + angle_dot) * 0.5 * (ATTENUATION * ATTENUATION + ATTENUATION) * 0.5;
	//float quantized_light = floor(light_strength * light_quant) / light_quant;
	
	DIFFUSE_LIGHT += LIGHT_AREA_DIFFUSE_MULTIPLIER * (light_strength) * 0.5 * LIGHT_COLOR;
}



//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
