shader_type spatial;

render_mode blend_mix, depth_draw_opaque, depth_prepass_alpha, cull_back, ensure_correct_normals, diffuse_burley, specular_schlick_ggx;
uniform vec4 albedo : source_color;
uniform sampler2D texture_albedo : hint_default_white, source_color, filter_nearest, repeat_enable;
uniform float roughness : hint_range(0, 1) = 1.0;
uniform sampler2D texture_metallic : hint_default_white, filter_nearest, repeat_enable;
uniform vec4 metallic_texture_channel = vec4(0.0);
uniform sampler2D texture_roughness : hint_roughness_r, filter_nearest, repeat_enable;
uniform float specular : hint_range(0, 1) = 0.5;
uniform float metallic : hint_range(0, 1) = 0.0;
uniform vec3 uv1_scale = vec3(1.0);
uniform vec3 uv1_offset = vec3(0.0);

const float phi = 45.0 * PI / 180.0;
uniform bool scaled = true;

void vertex() {
	UV = UV * uv1_scale.xy + uv1_offset.xy;
	
	// Scaled = 0 => scale = 1.0
	// Scaled = 1 => scale = 1.0/sin(phi)
	float scale = 1.0 + (1.0/sin(phi) - 1.0) * float(scaled);
	
	VERTEX.z -= scale * sin(phi) * VERTEX.y;
	VERTEX.y *= scale * cos(phi);
	
	mat3 model_matrix = mat3(vec3(1.0, 0.0, 0.0),
							 vec3(0.0, scale * cos(phi), 0.0),
							 vec3(0.0, -scale * sin(phi), 1.0));
	//MODELVIEW_MATRIX = VIEW_MATRIX * model_matrix; // Not needed
	MODELVIEW_NORMAL_MATRIX = mat3(VIEW_MATRIX) * inverse(model_matrix);
	//MODELVIEW_NORMAL_MATRIX = mat3(VIEW_MATRIX) * mat3(model_matrix);
	// Doesn't work because of non-uniformity (shear)
}

void fragment() {
	vec2 base_uv = UV;
	vec4 albedo_tex = texture(texture_albedo, base_uv);
	ALBEDO = albedo.rgb * albedo_tex.rgb;
	float metallic_tex = dot(texture(texture_metallic, base_uv), metallic_texture_channel);
	METALLIC = metallic_tex * metallic;
	vec4 roughness_texture_channel = vec4(1.0, 0.0, 0.0, 0.0);
	float roughness_tex = dot(texture(texture_roughness, base_uv), roughness_texture_channel);
	ROUGHNESS = roughness_tex * roughness;
	SPECULAR = specular;
	ALPHA *= albedo.a * albedo_tex.a;
}
