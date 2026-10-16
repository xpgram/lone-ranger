shader_type spatial;

#include "res://addons/material_layers/shaders/layer_lib.gdshaderinc"

// Helper functions

vec2 rotateUV(vec2 uv, float angle, vec2 pivot) {
    float angle_rad = radians(angle);
    vec2 pivot_internal = clamp(pivot, 0.0, 1.0);

    mat2 rotate = mat2(
    vec2(cos(angle_rad), -sin(angle_rad)),
    vec2(sin(angle_rad), cos(angle_rad))
	);
		
		uv -= pivot_internal;
		uv = rotate * uv;
		uv += pivot_internal;
		return uv;
	}
vec2 uvManip(vec2 uv, vec2 scale, float rotation, vec2 pivot, vec2 offset){  
    vec2 pivot_internal = clamp(pivot, 0.0, 1.0);
	uv -= pivot_internal;
    uv *= scale;
	uv = rotateUV(uv, rotation, vec2(0.5));
	uv += pivot_internal;
    uv += offset;
    return uv;
	}

//-----------------------------------------

group_uniforms UVControls;
uniform float UVScale = 1.0;
uniform vec2 UVOffset = vec2(0.0, 0.0);
uniform float UVRot : hint_range(0.0, 360.0) = 0.0;
uniform vec2 UVPivot = vec2(0.0, 0.0);

group_uniforms textures;
uniform sampler2D albedoTexture : source_color, filter_linear_mipmap_anisotropic;
uniform sampler2D roughnessTexture : filter_linear_mipmap_anisotropic;
uniform sampler2D normalTexture : filter_linear_mipmap_anisotropic;
uniform sampler2D aoTexture : filter_linear_mipmap_anisotropic;
uniform sampler2D heightTexture : filter_linear_mipmap_anisotropic;

void fragment() {
	SETUP_SURFACE_FRAGMENT;

	vec2 uv = uvManip(UV, vec2(UVScale), UVRot, UVPivot, UVOffset);
	
	vec3 albedo = texture(albedoTexture, uv).rgb;
	float roughness = texture(roughnessTexture, uv).r;
	vec3 normal = texture(normalTexture, uv).rgb;
	float ao = texture(aoTexture, uv).r;
	float height = texture(heightTexture, uv).r;

	// Output the sampled textures

	LAYER_OUT_ALBEDO = albedo;
	LAYER_OUT_ROUGHNESS = roughness;
	LAYER_OUT_NORMAL_MAP = normal;
	LAYER_OUT_AO = ao;
	LAYER_OUT_HEIGHT = height;

	// Assign to default output variables for material preview

	ALBEDO = LAYER_OUT_ALBEDO;
	ROUGHNESS = LAYER_OUT_ROUGHNESS;
	NORMAL_MAP = LAYER_OUT_NORMAL_MAP;
	AO = LAYER_OUT_AO;
	
}