shader_type canvas_item;

uniform bool remap_color = false;
uniform vec3 inner_color_remap: source_color = vec3(1, 1, 1);
uniform vec3 outline_color_remap: source_color = vec3(0, 0, 0);

const vec3 INNER_COLOR = vec3(1, 1, 1);
const vec3 OUTLINE_COLOR = vec3(63.0 / 255.0, 38.0 / 255.0, 49.0 / 255.0);

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Called for every pixel the material is visible on.
	if (remap_color){
		if (COLOR.rgb == INNER_COLOR){
			COLOR.rgb = inner_color_remap;
		} else if (COLOR.rgb == OUTLINE_COLOR){
			COLOR.rgb = outline_color_remap;
		}
	}
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
