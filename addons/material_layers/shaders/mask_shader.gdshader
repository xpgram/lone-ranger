shader_type spatial;

#include "res://addons/material_layers/shaders/layer_lib.gdshaderinc"


void vertex() {
	SETUP_MASK_VERTEX;



	// Mask vertex code goes here



	// Assign the modified VERTEX to the OUT variable
	LAYER_OUT_VERTEX = LAYER_BLEND_VERTEX;
}

void fragment() {
	SETUP_MASK_FRAGMENT;


	// Mask fragment code goes here
	float mask = 0.5;


	// Blending layer BASE and BLEND layer
	LAYER_OUT_ALBEDO = mix(LAYER_BASE_ALBEDO, LAYER_BLEND_ALBEDO, mask);
	LAYER_OUT_ROUGHNESS = mix(LAYER_BASE_ROUGHNESS, LAYER_BLEND_ROUGHNESS, mask);
	LAYER_OUT_NORMAL_MAP = mix(LAYER_BASE_NORMAL_MAP, LAYER_BLEND_NORMAL_MAP, mask);
	LAYER_OUT_AO = LAYER_BASE_AO * mix(1.0, LAYER_BLEND_AO, mask);
	LAYER_OUT_HEIGHT = mix(LAYER_BASE_HEIGHT, LAYER_BLEND_HEIGHT, mask);
	LAYER_OUT_METALLIC = mix(LAYER_BASE_METALLIC, LAYER_BLEND_METALLIC, mask);
	LAYER_OUT_EMISSION = mix(LAYER_BASE_EMISSION, LAYER_BLEND_EMISSION, mask);
}
