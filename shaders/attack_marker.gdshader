shader_type canvas_item;

uniform bool remap_color = false;
uniform vec3 color_remap: source_color = vec3(1, 1, 1);

const vec3 MAIN_COLOR = vec3(1, 1, 1);

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Called for every pixel the material is visible on.
	if (remap_color){
		if (COLOR.rgb == MAIN_COLOR){
			COLOR.rgb = color_remap;
		}
	}
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
