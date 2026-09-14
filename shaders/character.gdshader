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

uniform float offset = 0.0;

const vec3 OUTLINE_COLOR = vec3(63.0 / 255.0, 38.0 / 255.0, 49.0 / 255.0);

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

// from https://godotshaders.com/snippet/random-value/
float random (vec2 uv) {
    return fract(sin(dot(uv.xy,
        vec2(12.9898,78.233))) * 43758.5453123);
}

void vertex() {
	// Called for every vertex the material is visible on.
	vec2 diff = (vec2(0.5, 0.5) - UV) * scale_addition;
	VERTEX -= diff;
	
	// move x over time
	if (move_active){
		float pos_time = sin(TIME * position_speed + offset) / 2.0 + 0.5;
		VERTEX.x += mix(min_pos_offset, max_pos_offset, pos_time);
	}
}

void fragment() {
	// Called for every pixel the material is visible on.
	
	// rotate over time
	if (rotate_active){
		float rot_time = sin(TIME * rotation_speed + offset) / 2.0 + 0.5;
		float rotation = mix(min_rot_offset, max_rot_offset, rot_time) * PI / 2.0;
		vec2 rotated_uv = rotate(UV, vec2(0.5, 0.5), rotation);
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
		float shine_time = mod(TIME + offset, shine_speed);
		vec2 shine_point_a = vec2(shine_time, 0.0);
		vec2 shine_point_b = vec2(0.0, shine_time);
		float distance_to_shine = 
			abs(
				UV.x * (shine_point_b.y - shine_point_a.y)
				- UV.y * (shine_point_b.x - shine_point_a.x)
				+ shine_point_b.x * shine_point_a.y
				- shine_point_b.y * shine_point_a.x
			)
			/
			sqrt(
				pow(shine_point_b.y - shine_point_a.y, 2)
				+ pow(shine_point_b.x - shine_point_a.x, 2)
			);
		
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
