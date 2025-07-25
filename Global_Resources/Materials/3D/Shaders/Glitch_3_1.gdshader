shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_linear_mipmap;

uniform float sanity = 100.;
uniform bool inverted = true;

float lintp(float x, float x0, float x1) {
	/* Return a linear interpolation for x0 <= x <= x1, such
	   that lintp(x0) = 0 and lintp(x1) = 1 */
	return (x0 - x) / (x0 - x1);
}

void fragment() {  
// Parameters
	
	// Rotation
	float max_rotation = 0.15;
	
	// Inversion
		// hier gibts momentan noch nicht viel zu ändern
		
// Thresholds
	// If sanity is between the values, the corresponding effect happens
	vec2 thr_rotation = vec2(80., 0.);
	vec2 thr_inversion = vec2(10., 0.);
	
// Main shader
	// Get screen as texture
    COLOR = textureLod(screen_texture, SCREEN_UV, 0.0);
	
	// Rotation
	// The screen will rotate slightly back and forth
	if (thr_rotation.x >= sanity && sanity >= thr_rotation.y) {
		float angle = max_rotation * (1. - lintp(sanity, thr_rotation.y, thr_rotation.x)) * sin(TIME);
		mat2 rot = mat2(vec2(cos(angle), sin(angle)), vec2(-sin(angle), cos(angle)));
		COLOR = texture(screen_texture, rot * (SCREEN_UV - vec2(.5)) + vec2(.5));
	}
	
	// Inversion
	// Invert the screen and the colors
	if (thr_inversion.x >= sanity && sanity >= thr_inversion.y) {
		if (inverted) {
			vec4 col = texture(screen_texture, vec2(-SCREEN_UV.x + 1., -SCREEN_UV.y + 1.));
			COLOR.rgb = vec3(.5) - .5*col.rgb;
		}
	}
}