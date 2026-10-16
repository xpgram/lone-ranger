shader_type spatial;

#include "res://addons/material_layers/shaders/layer_lib.gdshaderinc"

// Helper functions

float getChannel(vec4 tex, int ch) {
	if (ch == 0) return tex.r;
	if (ch == 1) return tex.g;
	if (ch == 2) return tex.b;
	if (ch == 3) return tex.a;
	return 1.0;
}

float heightBlend(float h1, float h2, float height_offset, float contrast, float mask){
	height_offset = 1.0 - height_offset;
    float add1 = h1 + height_offset;
	float subtract1 = h2 - height_offset;
    float add2 = subtract1 + mask;
	float max1 = max(add1, add2);
	float subtract2 = max1 - add1;
	float multiply1 = subtract2 * (contrast * 30.0);
    float result = clamp(multiply1, 0.0, 1.0);
	return result;
}

vec3 normalCombine(vec3 n1, vec3 n2, float mask){
    vec2 blendedXY = n1.rg + (n2.rg - 0.5) * mask;
    float blendedZ = mix(n1.z, n1.z * n2.z, mask);
    return vec3(blendedXY, blendedZ);
}

//-----------------------------------------

group_uniforms heightBlending;
uniform int vertexColor : hint_enum("Red", "Green", "Blue", "Alpha", "None") = 0;
uniform float heightOffset : hint_range(0.0, 1.0) = 0.2;
uniform float heightContrast : hint_range(0.0, 1.0) = 0.2;
uniform bool invertHeight;


void fragment() {
    SETUP_MASK_FRAGMENT;


    float vertex_color = getChannel(COLOR, vertexColor);

    float mask = heightBlend(
        mix(1.0 - LAYER_BASE_HEIGHT,
        LAYER_BASE_HEIGHT, float(invertHeight)),
        LAYER_BLEND_HEIGHT, heightOffset,
        heightContrast, vertex_color);

    // Blend BASE and BLEND inputs with a mask and output the result

    LAYER_OUT_ALBEDO = mix(LAYER_BASE_ALBEDO, LAYER_BLEND_ALBEDO, mask);
	LAYER_OUT_ROUGHNESS = mix(LAYER_BASE_ROUGHNESS, LAYER_BLEND_ROUGHNESS, mask);
    LAYER_OUT_NORMAL_MAP = normalCombine(LAYER_BASE_NORMAL_MAP, LAYER_BLEND_NORMAL_MAP, mask);
    LAYER_OUT_AO = LAYER_BASE_AO * mix(1.0, LAYER_BLEND_AO, mask);
    LAYER_OUT_HEIGHT = LAYER_BASE_HEIGHT;
	
	ALBEDO = vec3(mask);

}
