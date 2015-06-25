extern vec4 colorFill;
vec4 effect (vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
	if (Texel(texture, texture_coords).rgba == vec4(0.0)) {
		discard;
	}
	return colorFill;
}