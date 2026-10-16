shader_type spatial;

#include "res://addons/material_layers/shaders/layer_lib.gdshaderinc"


void vertex() {
	SETUP_SURFACE_VERTEX;



	// Surface vertex code goes here



	// Assign the modified VERTEX to the OUT variable
	LAYER_OUT_VERTEX = VERTEX;
	
	// Output for material preview and thumbnail generation
	// Not used in material layering
	VERTEX = LAYER_OUT_VERTEX;
}

void fragment() {
	SETUP_SURFACE_FRAGMENT;
	

	
	// Surface fragment code goes here



	// Layer outputs
	LAYER_OUT_ALBEDO = vec3(0.7);
	LAYER_OUT_ROUGHNESS = 1.0;
	LAYER_OUT_NORMAL_MAP = vec3(0.5, 0.5, 1.0);
	LAYER_OUT_AO = 1.0;
	LAYER_OUT_HEIGHT = 0.5;
	LAYER_OUT_METALLIC = 0.0;
	LAYER_OUT_EMISSION = vec3(0.0);

	// Outputs for material preview and thumbnail generation
	// Not used in material layering
	ALBEDO = LAYER_OUT_ALBEDO;
	ROUGHNESS = LAYER_OUT_ROUGHNESS;
	NORMAL_MAP = LAYER_OUT_NORMAL_MAP;
	AO = LAYER_OUT_AO;
	METALLIC = LAYER_OUT_METALLIC;
	EMISSION = LAYER_OUT_EMISSION;
}
