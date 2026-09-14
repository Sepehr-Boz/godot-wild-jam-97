shader_type canvas_item;

uniform bool has_inline = true;
uniform float inline_width = 0.01;
uniform vec4 inline_color: source_color = vec4(0, 0, 0, 1);

uniform ivec2 atlas_index;

const ivec2 TEXTURE_SIZE = ivec2(203, 186);
const ivec2 TILE_SIZE = ivec2(16, 16);
const ivec2 TILE_SEPARATION = ivec2(1, 1);
const ivec2 MARGIN_SIZE = ivec2(0, 0);
const vec2 NORMALIZED_TILE_SIZE = vec2(TILE_SIZE) / vec2(TEXTURE_SIZE);
const vec2 NORMALIZED_SEPARATION_SIZE = vec2(TILE_SEPARATION) / vec2(TEXTURE_SIZE);
const vec2 NORMALIZED_MARGIN_SIZE = vec2(MARGIN_SIZE) / vec2(TEXTURE_SIZE);

varying vec2 center_of_tile;
varying vec2 start_of_tile;
varying vec2 end_of_tile;

void vertex() {
	// Called for every vertex the material is visible on.
	start_of_tile = NORMALIZED_MARGIN_SIZE
		+ (NORMALIZED_TILE_SIZE * vec2(atlas_index))
		+ (vec2(NORMALIZED_SEPARATION_SIZE) * vec2(atlas_index));
	center_of_tile = start_of_tile + NORMALIZED_TILE_SIZE / 2.0;
	end_of_tile = start_of_tile + NORMALIZED_TILE_SIZE;
}

void fragment() {
	// Called for every pixel the material is visible on.
	COLOR = texture(TEXTURE, UV);
	if (has_inline){
		bool is_edge = distance(UV.x, center_of_tile.x) >= inline_width
			|| distance(UV.y, center_of_tile.y) >= inline_width;
		if (is_edge){
			COLOR = inline_color;
		}
	}
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
