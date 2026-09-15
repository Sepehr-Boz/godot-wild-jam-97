shader_type canvas_item;

uniform bool has_inline = true;
uniform float inline_width_pixels: hint_range(0, 8, 0.5) = 0.5;
uniform vec4 inline_color: source_color = vec4(0, 0, 0, 1);

const float WIDTH_INCREMENT = 0.5 / 8.0;
varying float inline_width;

void vertex() {
	// Called for every vertex the material is visible on.
	inline_width = inline_width_pixels * WIDTH_INCREMENT;
}

void fragment() {
	// Called for every pixel the material is visible on.
	COLOR = texture(TEXTURE, UV);
	if (has_inline){
		bool is_edge = UV.x <= inline_width
			|| UV.x >= (1.0 - inline_width)
			|| UV.y <= inline_width
			|| UV.y >= (1.0 - inline_width);
		if (is_edge){
			COLOR = inline_color;
		}
	}
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
