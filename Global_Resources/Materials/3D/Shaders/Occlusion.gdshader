shader_type spatial;

uniform vec4 albedo : source_color;
uniform sampler2D texture_albedo : hint_default_white, source_color, filter_nearest, repeat_enable;

void fragment() {
	vec2 base_uv = UV;
	vec4 albedo_tex = texture(texture_albedo, base_uv);
	ALBEDO = albedo.rgb * albedo_tex.rgb;
	ALPHA *= albedo.a * albedo_tex.a;
}
