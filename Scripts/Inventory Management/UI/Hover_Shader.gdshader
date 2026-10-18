shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;


uniform float blur_amount : hint_range(0.0, 5.0) = 2.0;
uniform vec4 tint_color : source_color = vec4(0.0, 0.0, 0.0, 0.3);


uniform vec4 border_color : source_color = vec4(1.0, 0.5, 0.0, 1.0); // Orange border
uniform float border_thickness : hint_range(0.0, 0.1) = 0.02; // Thickness relative to panel size

void fragment() {
    // 1. Calculate the blurred and tinted background
    vec3 blurred_bg = textureLod(screen_texture, SCREEN_UV, blur_amount).rgb;
    vec3 mixed_color = mix(blurred_bg, tint_color.rgb, tint_color.a);
    
    // 2. Check if the current pixel is near any of the 4 edges (UV maps from 0.0 to 1.0)
    bool is_border = (UV.x < border_thickness || UV.x > 1.0 - border_thickness ||
                      UV.y < border_thickness || UV.y > 1.0 - border_thickness);
    
    // 3. If it's on the border, mix in the border color based on its alpha channel
    if (is_border) {
        COLOR = vec4(mix(mixed_color, border_color.rgb, border_color.a), 1.0);
    } else {
        COLOR = vec4(mixed_color, 1.0);
    }
}
