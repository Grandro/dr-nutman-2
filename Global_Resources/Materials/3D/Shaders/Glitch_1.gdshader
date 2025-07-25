shader_type canvas_item;
// ursprünglich aus https://github.com/kuravih/gllock/blob/master/shaders/glitch.fragment.glsl

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_linear_mipmap;

uniform float sanity = 40.;


float basically_rand(vec2 co){
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453) * 2.0 - 1.0;
}

float offset(float blocks, vec2 uv, float vert, float time) {
   if (vert == 0.) {
        return basically_rand(vec2(time, floor(uv.y * blocks)));
   }
   return basically_rand(vec2(time, floor(uv.x * blocks)));
}

void fragment()
{
    //sanity = 100. - TIME;
    //if (sanity < 0.) sanity = 0.;
    
    float pi = 3.1415;
    
    vec3 angles = vec3(pi/3., pi/2., 0.);
    vec3 max_disp = vec3(0.0002, 0.0002, 0.0002) * (100. - sanity);
    vec3 segments = vec3(13., 17., 11.);
    vec3 vertical = vec3(0., 0., 1.);

    //COLOR = texture(TEXTURE, UV);
    COLOR = textureLod(screen_texture, SCREEN_UV, 0.0);
    
    COLOR.r = texture(screen_texture, SCREEN_UV + vec2(cos(angles.r), sin(angles.r)) * max_disp.r * offset(segments.r, UV, vertical.r, TIME)).r;
    COLOR.g = texture(screen_texture, SCREEN_UV + vec2(cos(angles.g), sin(angles.g)) * max_disp.g * offset(segments.g, UV, vertical.g, TIME)).g;
    COLOR.b = texture(screen_texture, SCREEN_UV + vec2(cos(angles.b), sin(angles.b)) * max_disp.b * offset(segments.b, UV, vertical.b, TIME)).b;
    
    //COLOR.r = 0.;
    //COLOR.g = 0.;
    //COLOR.b = 0.;
    
}