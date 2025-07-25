shader_type canvas_item;
// ursprünglicher glitch shader aus https://github.com/kuravih/gllock/blob/master/shaders/glitch.fragment.glsl

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_linear_mipmap;

uniform float sanity = 100.;
const float pi = 3.1416;

// Helper functions
float basically_rand(vec2 co) {
	/* Return a "random" number between 0 and 1.
	   (That is, the result appears random for a non-continuous set of co) */
    return fract(sin(dot(co.xy, vec2(12.9898,78.233))) * 43758.5453) * 2.0 - 1.0;
}

vec4 basically_rand4(vec2 co) {
	// Return 4 "random" numbers
	float a = basically_rand(co);
	float b = basically_rand(co + vec2(.23, 1.45));
	float c = basically_rand(co + vec2(.67, 1.98));
	float d = basically_rand(co + vec2(.83, 1.72));
    return vec4(a, b, c, d);
}

float offset(float blocks, vec2 uv, float vert, float time) {
	// better comment next time
   if (vert == 0.) {
        return basically_rand(vec2(time, floor(uv.y * blocks)));
   }
   return basically_rand(vec2(time, floor(uv.x * blocks)));
}

float sup_norm(vec2 v) {
	// Return the sup norm of a 2D-vector
    return max(abs(v.x), abs(v.y));
}

float lintp(float x, float x0, float x1) {
	/* Return a linear interpolation for x0 <= x <= x1, such
	   that lintp(x0) = 0 and lintp(x1) = 1 */
	return (x0 - x) / (x0 - x1);
}

void fragment() {  
// Parameters

	// RGB Messup
		// Angles of displacement (in rad)
    vec3 angles = vec3(-pi/2., 5.*pi/6., pi/6.);
		// Max. displacement (where 1 is size of the color_rect the shader is applied to)
		// Starts at 0 (sanity = 100) for all colours and increases linearly to 0.02
    vec3 max_disp = vec3(0.0002, 0.0002, 0.0002) * (100. - sanity);
		// Amount of segments (screen divisions) for each colour
    vec3 seg = vec3(13., 17., 11.);
		// Bool, 0 = horizontal segment, 1 = vertical segment
    vec3 vert = vec3(0., 0., 1.);

	// Pixel effect
		// Size of the black and white rectangles (where 1 is size of the color_rect)
	float max_rectsize = 0.008;
		// Max. opycity of the rectangles
	float max_opacity = 0.8;
	
	// Darkness
		// hier gibts momentan noch nicht viel zu ändern
		
// Thresholds
	// If sanity is between the values, the corresponding effect happens
	vec2 thr_rgbmess = vec2(100., 0.);
	vec2 thr_pixels = vec2(60., 0.);
	vec2 thr_darkness = vec2(100., 0.);


// Main shader

	// Get screen as texture
    COLOR = textureLod(screen_texture, SCREEN_UV, 0.0);
	
	// RGB messup
	// Displace red, green and blue parts of the screen seperately
	if (thr_rgbmess.x >= sanity && sanity >= thr_rgbmess.y ) {
		COLOR.r = texture(screen_texture, SCREEN_UV + vec2(cos(angles.r), sin(angles.r)) * max_disp.r * offset(seg.r, UV, vert.r, TIME)).r;
    	COLOR.g = texture(screen_texture, SCREEN_UV + vec2(cos(angles.g), sin(angles.g)) * max_disp.g * offset(seg.g, UV, vert.g, TIME)).g;
    	COLOR.b = texture(screen_texture, SCREEN_UV + vec2(cos(angles.b), sin(angles.b)) * max_disp.b * offset(seg.b, UV, vert.b, TIME)).b;	
	}
   
	// Pixel effect
	// Create a black and a white rectangle of size rect_size randomly on the screen for each time step
	if (thr_pixels.x >= sanity && sanity >= thr_pixels.y) {
		float rect_size = max_rectsize * lintp(sanity, thr_pixels.x, thr_pixels.y); 
		vec4 rand4 = 0.5 * basically_rand4(vec2(TIME + 1., TIME - 1.));
		
	    if (sup_norm(SCREEN_UV  - vec2(.5 + rand4.x, .5 + rand4.y)) < rect_size) {
			COLOR.rgb = vec3(0.);
			COLOR.a = max_opacity * (lintp(sanity, thr_pixels.y, thr_pixels.x));
	    }
	    if (sup_norm(SCREEN_UV  - vec2(.5 + rand4.z, .5 + rand4.a)) < rect_size) {
			COLOR.rgb = vec3(1.);
			COLOR.a = max_opacity * (lintp(sanity, thr_pixels.x, thr_pixels.y));
	    }
	}
	
	// Darkness
	// The edge of the screen becomes darker
	if (thr_darkness.x >= sanity && sanity >= thr_darkness.y) {
		COLOR.xyz *= (1. - smoothstep(2. - 4.*(1. - sanity/100.), 2., 2.*sup_norm(SCREEN_UV - vec2(.5, .5))));
	}
}