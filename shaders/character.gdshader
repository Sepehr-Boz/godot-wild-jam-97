shader_type canvas_item;

uniform bool move_active = true;
uniform float position_speed = 1.0;
uniform float min_pos_offset = -0.5;
uniform float max_pos_offset = 0.5;

uniform bool rotate_active = true;
uniform float rotation_speed = 1.0;
uniform float min_rot_offset: hint_range(0.0, 1.0, 0.1) = 0.95;
uniform float max_rot_offset: hint_range(1.0, 2.0, 0.1) = 1.05;

uniform bool shine_active = true;
uniform float shine_speed = 1.0;
uniform float shine_width: hint_range(0.0, 1.0, 0.0001) = 0.01;
uniform vec3 shine_color: source_color = vec3(1, 1, 1);

uniform vec2 scale_addition = vec2(0.0, 0.0);

uniform bool remap_outline = false;
uniform vec3 remapped_outline_color: source_color = vec3(1, 1, 1);

uniform ivec2 atlas_index;

const ivec2 ATLAS_SIZE = ivec2(12, 11);
const vec2 tile_size = vec2(1.0, 1.0) / vec2(ATLAS_SIZE);
const vec3 OUTLINE_COLOR = vec3(63.0 / 255.0, 38.0 / 255.0, 49.0 / 255.0);

varying vec2 center_of_tile;
varying vec2 start_of_tile;
varying vec2 end_of_tile;
varying float time_offset;

// from https://godotshaders.com/shader/rotate-texture/
vec2 rotate(vec2 uv, vec2 pivot, float angle)
{
	mat2 rotation = mat2(vec2(sin(angle), -cos(angle)),
			vec2(cos(angle), sin(angle)));
    
    uv -= pivot;
    uv = uv * rotation;
    uv += pivot;
    return uv;
}

void vertex() {
	// Called for every vertex the material is visible on.
	start_of_tile = tile_size * vec2(atlas_index);
	center_of_tile = start_of_tile + tile_size / 2.0;
	end_of_tile = start_of_tile + tile_size;
	time_offset = float(atlas_index.x * atlas_index.y);
	
	vec2 diff = (center_of_tile - UV) * scale_addition;
	VERTEX -= diff;
	//VERTEX *= 1.0 + scale_addition;
	
	// move x over time
	if (move_active){
		float pos_time = sin(TIME * position_speed + time_offset) / 2.0 + 0.5;
		VERTEX.x += mix(min_pos_offset, max_pos_offset, pos_time);
	}
}

void fragment() {
	// Called for every pixel the material is visible on.
	
	// rotate over time
	if (rotate_active){
		float rot_time = sin(TIME * rotation_speed + time_offset) / 2.0 + 0.5;
		float rotation = mix(min_rot_offset, max_rot_offset, rot_time) * PI / 2.0;
		vec2 rotated_uv = rotate(UV, center_of_tile, rotation);
		COLOR = texture(TEXTURE, rotated_uv);
	}
	else{
		COLOR = texture(TEXTURE, UV);
	}
	
	// check if should shine
	// since in a tilemap can then loop time 0-1 and check if that overlaps
	// with the uv so check for if should shine at that time
	// dont shine over the outline
	if (shine_active && COLOR.rgb != OUTLINE_COLOR){
		float shine_time = mod(TIME * shine_speed + float(atlas_index.x) / float(atlas_index.y), 1.0);
		float distance_to_shine = distance(UV.x, shine_time);
		if (distance_to_shine <= shine_width){
			COLOR.rgb = shine_color;
		}
	}
	
	if (remap_outline && COLOR.rgb == OUTLINE_COLOR){
		COLOR.rgb = remapped_outline_color;
	}
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
