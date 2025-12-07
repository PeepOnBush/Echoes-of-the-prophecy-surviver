shader_type canvas_item;

uniform bool active = false;

void fragment() {
	vec4 origin_color = texture(TEXTURE, UV);
	if (active) {
		// Turn the pixel pure white, but keep the alpha (transparency)
		COLOR = vec4(1.0, 1.0, 1.0, origin_color.a);
	} else {
		COLOR = origin_color;
	}
}