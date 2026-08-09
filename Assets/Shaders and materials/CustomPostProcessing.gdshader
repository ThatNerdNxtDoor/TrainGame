shader_type canvas_item;
uniform sampler2D bg : hint_screen_texture;

uniform vec3 burn_color: source_color;

uniform float vin_strength = 0.5;
void vertex() {
	// Called for every vertex the material is visible on.
}

const float[4] dither_pattern = float[4](
	0.5, .25,
	0.0, .75
);

void fragment() {
	vec4 screen_color = texture(bg, SCREEN_UV);
	//screen_color.rgb = vec3(screen_color.r + screen_color.g + screen_color.b) / 3.0;
	
	
	
	vec2 distance_to_center_sqr = (SCREEN_UV * 2.0) - 1.0;
	distance_to_center_sqr *= distance_to_center_sqr;
	float vin = (1.0 - distance_to_center_sqr.x) * (1.0 - distance_to_center_sqr.y);
	
	/*screen_color = screen_color * vec4(vec3(vin * vin_strength + (1.0 - vin_strength)), 1.0);
	ivec2 dither_pos = ivec2(SCREEN_UV / (SCREEN_PIXEL_SIZE * 2.0));
	float dither_value = dither_pattern[(dither_pos.x % 2) + (dither_pos.y % 2) * 2];
	screen_color = (floor(screen_color * 64.0 + dither_value + 0.2) - 0.2) / 64.0;
	*/
	screen_color.rgb = 1.0 - (1.0 - screen_color.rgb) * (2.0 - burn_color);
	COLOR = screen_color;
	// Called for every pixel the material is visible on.
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
