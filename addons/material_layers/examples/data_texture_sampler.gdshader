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

group_uniforms textureSampler;
uniform sampler2D texture : filter_linear_mipmap_anisotropic;
uniform int layerOutput : hint_range(0, 15);

group_uniforms UVControls;
uniform int UVSelect : hint_enum("UV1", "UV2") = 0;
uniform float UVScale = 1.0;
uniform vec2 UVOffset = vec2(0.0, 0.0);
uniform float UVRot : hint_range(0.0, 360.0) = 0.0;
uniform vec2 UVPivot = vec2(0.0, 0.0);


void fragment() {
    SETUP_DATA_FRAGMENT;
    
    vec2 uv = mix(UV, UV2, float(UVSelect));
    uv = uvManip(uv, vec2(UVScale), UVRot, UVPivot, UVOffset);

	vec4 sampled_texture = texture(texture, uv);

    // Output texture to selected slot

    switch (layerOutput) {
    case 0: LAYER_OUT_TEX_0 = sampled_texture; break;
    case 1: LAYER_OUT_TEX_1 = sampled_texture; break;
    case 2: LAYER_OUT_TEX_2 = sampled_texture; break;
    case 3: LAYER_OUT_TEX_3 = sampled_texture; break;
    case 4: LAYER_OUT_TEX_4 = sampled_texture; break;
    case 5: LAYER_OUT_TEX_5 = sampled_texture; break;
    case 6: LAYER_OUT_TEX_6 = sampled_texture; break;
    case 7: LAYER_OUT_TEX_7 = sampled_texture; break;
    case 8: LAYER_OUT_TEX_8 = sampled_texture; break;
    case 9: LAYER_OUT_TEX_9 = sampled_texture; break;
    case 10: LAYER_OUT_TEX_10 = sampled_texture; break;
    case 11: LAYER_OUT_TEX_11 = sampled_texture; break;
    case 12: LAYER_OUT_TEX_12 = sampled_texture; break;
    case 13: LAYER_OUT_TEX_13 = sampled_texture; break;
    case 14: LAYER_OUT_TEX_14 = sampled_texture; break;
    case 15: LAYER_OUT_TEX_15 = sampled_texture; break;
}
	ALBEDO = sampled_texture.rgb;
}