shader_type canvas_item;

uniform vec2 subpixel_vector = vec2(0.0);

void vertex() {
	VERTEX += subpixel_vector;
}
