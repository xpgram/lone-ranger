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

group_uniforms heightBlend;
uniform int vertexColor : hint_enum("Red", "Green", "Blue", "Alpha", "None") = 0;
uniform bool invertHeight;
uniform float heightOffset : hint_range(0.0, 1.0) = 0.2;
uniform float heightContrast : hint_range(0.0, 1.0) = 0.2;

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
	SETUP_OVERLAY_FRAGMENT;

	vec2 uv = uvManip(UV, vec2(UVScale), UVRot, UVPivot, UVOffset);

	vec3 albedo = texture(albedoTexture, uv).rgb;
	float roughness = texture(roughnessTexture, uv).r;
	vec3 normal = texture(normalTexture, uv).rgb;
	float ao = texture(aoTexture, uv).r;
	float height = texture(heightTexture, uv).r;

	float vertex_color = getChannel(COLOR, vertexColor);
    float mask = heightBlend(mix(1.0 - LAYER_BELOW_HEIGHT, LAYER_BELOW_HEIGHT, float(invertHeight)), height, heightOffset, heightContrast, vertex_color);

	// Blend this layer with the layer below and output the result

	LAYER_OUT_ALBEDO = mix(LAYER_BELOW_ALBEDO, albedo, mask);
	LAYER_OUT_ROUGHNESS = mix(LAYER_BELOW_ROUGHNESS, roughness, mask);
	LAYER_OUT_NORMAL_MAP = normalCombine(LAYER_BELOW_NORMAL_MAP, normal, mask);
	LAYER_OUT_AO = LAYER_BELOW_AO * mix(1.0, ao, mask);
	LAYER_OUT_HEIGHT = LAYER_BELOW_HEIGHT;
	
	ALBEDO = albedo;
	ROUGHNESS = roughness;
	NORMAL_MAP = normal;
	AO = ao;


	
}