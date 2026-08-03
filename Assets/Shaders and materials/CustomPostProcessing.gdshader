shader_type canvas_item;
uniform sampler2D bg : hint_screen_texture;

uniform float vin_strength = 0.5;
void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec4 screen_color = texture(bg, SCREEN_UV);
	screen_color.rgb = vec3(screen_color.r + screen_color.g + screen_color.b) / 3.0;
	
	vec2 distance_to_center_sqr = (SCREEN_UV * 2.0) - 1.0;
	distance_to_center_sqr *= distance_to_center_sqr;
	float vin = (1.0 - distance_to_center_sqr.x) * (1.0 - distance_to_center_sqr.y);
	
	COLOR = screen_color * vec4(vec3(vin * vin_strength + (1.0 - vin_strength)), 1.0);
	// Called for every pixel the material is visible on.
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
