shader_type canvas_item;

uniform bool whiten = false;
uniform float mix_weight = 1.0;

void fragment() {
	vec4 texture_color = texture(TEXTURE, UV);
}