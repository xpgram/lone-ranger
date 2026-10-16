
// [[[[[[[[[[[[[[[[[[[ Surface Material ]]]]]]]]]]]]]]]]]]] \\
#define SETUP_SURFACE_FRAGMENT \
vec3    LAYER_OUT_ALBEDO; \
vec3    LAYER_OUT_NORMAL_MAP; \
float   LAYER_OUT_ROUGHNESS; \
float   LAYER_OUT_HEIGHT; \
float   LAYER_OUT_AO; \
float   LAYER_OUT_METALLIC; \
vec3    LAYER_OUT_EMISSION; \
vec3    LAYER_OUT_BENT_NORMAL; \
vec3    LAYER_OUT_MESH_NORMAL_MAP; \
float   LAYER_OUT_MESH_AO; \
float   LAYER_OUT_MESH_HEIGHT; \
float   LAYER_OUT_MESH_CURVATURE; \
float   LAYER_OUT_MESH_THICKNESS; \
vec4    LAYER_BELOW_TEX_0; \
vec4    LAYER_BELOW_TEX_1; \
vec4    LAYER_BELOW_TEX_2; \
vec4    LAYER_BELOW_TEX_3; \
vec4    LAYER_BELOW_TEX_4; \
vec4    LAYER_BELOW_TEX_5; \
vec4    LAYER_BELOW_TEX_6; \
vec4    LAYER_BELOW_TEX_7; \
vec4    LAYER_BELOW_TEX_8; \
vec4    LAYER_BELOW_TEX_9; \
vec4    LAYER_BELOW_TEX_10; \
vec4    LAYER_BELOW_TEX_11; \
vec4    LAYER_BELOW_TEX_12; \
vec4    LAYER_BELOW_TEX_13; \
vec4    LAYER_BELOW_TEX_14; \
vec4    LAYER_BELOW_TEX_15; \
float    LAYER_BELOW_MASK_0; \
float    LAYER_BELOW_MASK_1; \
float    LAYER_BELOW_MASK_2; \
float    LAYER_BELOW_MASK_3; \
float    LAYER_BELOW_MASK_4; \
float    LAYER_BELOW_MASK_5; \
float    LAYER_BELOW_MASK_6; \
float    LAYER_BELOW_MASK_7; \
float    LAYER_BELOW_MASK_8; \
float    LAYER_BELOW_MASK_9; \
float    LAYER_BELOW_MASK_10; \
float    LAYER_BELOW_MASK_11; \
float    LAYER_BELOW_MASK_12; \
float    LAYER_BELOW_MASK_13; \
float    LAYER_BELOW_MASK_14; \
float    LAYER_BELOW_MASK_15 \

#define SETUP_SURFACE_VERTEX \
vec3    LAYER_OUT_VERTEX; \
float   LAYER_OUT_HEIGHT; \
vec4    LAYER_BELOW_TEX_0; \
vec4    LAYER_BELOW_TEX_1; \
vec4    LAYER_BELOW_TEX_2; \
vec4    LAYER_BELOW_TEX_3; \
vec4    LAYER_BELOW_TEX_4; \
vec4    LAYER_BELOW_TEX_5; \
vec4    LAYER_BELOW_TEX_6; \
vec4    LAYER_BELOW_TEX_7; \
float    LAYER_BELOW_MASK_0; \
float    LAYER_BELOW_MASK_1; \
float    LAYER_BELOW_MASK_2; \
float    LAYER_BELOW_MASK_3; \
float    LAYER_BELOW_MASK_4; \
float    LAYER_BELOW_MASK_5; \
float    LAYER_BELOW_MASK_6; \
float    LAYER_BELOW_MASK_7 \

// [[[[[[[[[[[[[[[[[[[ Mask Material ]]]]]]]]]]]]]]]]]]] \\

#define SETUP_MASK_FRAGMENT \
vec3    LAYER_BLEND_ALBEDO; \
vec3    LAYER_BLEND_NORMAL_MAP; \
float   LAYER_BLEND_ROUGHNESS; \
float   LAYER_BLEND_HEIGHT; \
float   LAYER_BLEND_AO; \
float   LAYER_BLEND_METALLIC; \
vec3    LAYER_BLEND_EMISSION; \
vec3    LAYER_BLEND_BENT_NORMAL; \
vec3    LAYER_BLEND_MESH_NORMAL_MAP; \
float   LAYER_BLEND_MESH_AO; \
float   LAYER_BLEND_MESH_HEIGHT; \
float   LAYER_BLEND_MESH_CURVATURE; \
float   LAYER_BLEND_MESH_THICKNESS; \
vec3    LAYER_BASE_ALBEDO; \
vec3    LAYER_BASE_NORMAL_MAP; \
float   LAYER_BASE_ROUGHNESS; \
float   LAYER_BASE_HEIGHT; \
float   LAYER_BASE_AO; \
float   LAYER_BASE_METALLIC; \
vec3    LAYER_BASE_EMISSION; \
vec3    LAYER_BASE_BENT_NORMAL; \
vec3    LAYER_BASE_MESH_NORMAL_MAP; \
float   LAYER_BASE_MESH_AO; \
float   LAYER_BASE_MESH_HEIGHT; \
float   LAYER_BASE_MESH_CURVATURE; \
float   LAYER_BASE_MESH_THICKNESS; \
vec3    LAYER_OUT_ALBEDO; \
vec3    LAYER_OUT_NORMAL_MAP; \
float   LAYER_OUT_ROUGHNESS; \
float   LAYER_OUT_HEIGHT; \
float   LAYER_OUT_AO; \
float   LAYER_OUT_METALLIC; \
vec3    LAYER_OUT_EMISSION; \
vec3    LAYER_OUT_BENT_NORMAL; \
vec3    LAYER_OUT_MESH_NORMAL_MAP; \
float   LAYER_OUT_MESH_AO; \
float   LAYER_OUT_MESH_HEIGHT; \
float   LAYER_OUT_MESH_CURVATURE; \
float   LAYER_OUT_MESH_THICKNESS; \
vec4    LAYER_BELOW_TEX_0; \
vec4    LAYER_BELOW_TEX_1; \
vec4    LAYER_BELOW_TEX_2; \
vec4    LAYER_BELOW_TEX_3; \
vec4    LAYER_BELOW_TEX_4; \
vec4    LAYER_BELOW_TEX_5; \
vec4    LAYER_BELOW_TEX_6; \
vec4    LAYER_BELOW_TEX_7; \
vec4    LAYER_BELOW_TEX_8; \
vec4    LAYER_BELOW_TEX_9; \
vec4    LAYER_BELOW_TEX_10; \
vec4    LAYER_BELOW_TEX_11; \
vec4    LAYER_BELOW_TEX_12; \
vec4    LAYER_BELOW_TEX_13; \
vec4    LAYER_BELOW_TEX_14; \
vec4    LAYER_BELOW_TEX_15; \
float    LAYER_BELOW_MASK_0; \
float    LAYER_BELOW_MASK_1; \
float    LAYER_BELOW_MASK_2; \
float    LAYER_BELOW_MASK_3; \
float    LAYER_BELOW_MASK_4; \
float    LAYER_BELOW_MASK_5; \
float    LAYER_BELOW_MASK_6; \
float    LAYER_BELOW_MASK_7; \
float    LAYER_BELOW_MASK_8; \
float    LAYER_BELOW_MASK_9; \
float    LAYER_BELOW_MASK_10; \
float    LAYER_BELOW_MASK_11; \
float    LAYER_BELOW_MASK_12; \
float    LAYER_BELOW_MASK_13; \
float    LAYER_BELOW_MASK_14; \
float    LAYER_BELOW_MASK_15 \

#define SETUP_MASK_VERTEX \
vec3    LAYER_BASE_VERTEX; \
float   LAYER_BASE_HEIGHT; \
vec3    LAYER_BLEND_VERTEX; \
float   LAYER_BLEND_HEIGHT; \
vec3    LAYER_OUT_VERTEX; \
float   LAYER_OUT_HEIGHT; \
vec4    LAYER_BELOW_TEX_0; \
vec4    LAYER_BELOW_TEX_1; \
vec4    LAYER_BELOW_TEX_2; \
vec4    LAYER_BELOW_TEX_3; \
vec4    LAYER_BELOW_TEX_4; \
vec4    LAYER_BELOW_TEX_5; \
vec4    LAYER_BELOW_TEX_6; \
vec4    LAYER_BELOW_TEX_7; \
float    LAYER_BELOW_MASK_0; \
float    LAYER_BELOW_MASK_1; \
float    LAYER_BELOW_MASK_2; \
float    LAYER_BELOW_MASK_3; \
float    LAYER_BELOW_MASK_4; \
float    LAYER_BELOW_MASK_5; \
float    LAYER_BELOW_MASK_6; \
float    LAYER_BELOW_MASK_7 \

// [[[[[[[[[[[[[[[[[[[ Overlay Material ]]]]]]]]]]]]]]]]]]] \\

#define SETUP_OVERLAY_FRAGMENT \
vec3    LAYER_BELOW_ALBEDO; \
vec3    LAYER_BELOW_NORMAL_MAP; \
float   LAYER_BELOW_ROUGHNESS; \
float   LAYER_BELOW_HEIGHT; \
float   LAYER_BELOW_AO; \
float   LAYER_BELOW_METALLIC; \
vec3    LAYER_BELOW_EMISSION; \
vec3    LAYER_BELOW_BENT_NORMAL; \
vec3    LAYER_BELOW_MESH_NORMAL_MAP; \
float   LAYER_BELOW_MESH_AO; \
float   LAYER_BELOW_MESH_HEIGHT; \
float   LAYER_BELOW_MESH_CURVATURE; \
float   LAYER_BELOW_MESH_THICKNESS; \
vec3    LAYER_OUT_ALBEDO; \
vec3    LAYER_OUT_NORMAL_MAP; \
float   LAYER_OUT_ROUGHNESS; \
float   LAYER_OUT_HEIGHT; \
float   LAYER_OUT_AO; \
float   LAYER_OUT_METALLIC; \
vec3    LAYER_OUT_EMISSION; \
vec3    LAYER_OUT_BENT_NORMAL; \
vec3    LAYER_OUT_MESH_NORMAL_MAP; \
float   LAYER_OUT_MESH_AO; \
float   LAYER_OUT_MESH_HEIGHT; \
float   LAYER_OUT_MESH_CURVATURE; \
float   LAYER_OUT_MESH_THICKNESS; \
vec4    LAYER_BELOW_TEX_0; \
vec4    LAYER_BELOW_TEX_1; \
vec4    LAYER_BELOW_TEX_2; \
vec4    LAYER_BELOW_TEX_3; \
vec4    LAYER_BELOW_TEX_4; \
vec4    LAYER_BELOW_TEX_5; \
vec4    LAYER_BELOW_TEX_6; \
vec4    LAYER_BELOW_TEX_7; \
vec4    LAYER_BELOW_TEX_8; \
vec4    LAYER_BELOW_TEX_9; \
vec4    LAYER_BELOW_TEX_10; \
vec4    LAYER_BELOW_TEX_11; \
vec4    LAYER_BELOW_TEX_12; \
vec4    LAYER_BELOW_TEX_13; \
vec4    LAYER_BELOW_TEX_14; \
vec4    LAYER_BELOW_TEX_15; \
float    LAYER_BELOW_MASK_0; \
float    LAYER_BELOW_MASK_1; \
float    LAYER_BELOW_MASK_2; \
float    LAYER_BELOW_MASK_3; \
float    LAYER_BELOW_MASK_4; \
float    LAYER_BELOW_MASK_5; \
float    LAYER_BELOW_MASK_6; \
float    LAYER_BELOW_MASK_7; \
float    LAYER_BELOW_MASK_8; \
float    LAYER_BELOW_MASK_9; \
float    LAYER_BELOW_MASK_10; \
float    LAYER_BELOW_MASK_11; \
float    LAYER_BELOW_MASK_12; \
float    LAYER_BELOW_MASK_13; \
float    LAYER_BELOW_MASK_14; \
float    LAYER_BELOW_MASK_15 \

#define SETUP_OVERLAY_VERTEX \
vec3    LAYER_BELOW_VERTEX; \
float   LAYER_BELOW_HEIGHT; \
vec3    LAYER_OUT_VERTEX; \
float   LAYER_OUT_HEIGHT; \
vec4    LAYER_BELOW_TEX_0; \
vec4    LAYER_BELOW_TEX_1; \
vec4    LAYER_BELOW_TEX_2; \
vec4    LAYER_BELOW_TEX_3; \
vec4    LAYER_BELOW_TEX_4; \
vec4    LAYER_BELOW_TEX_5; \
vec4    LAYER_BELOW_TEX_6; \
vec4    LAYER_BELOW_TEX_7; \
float    LAYER_BELOW_MASK_0; \
float    LAYER_BELOW_MASK_1; \
float    LAYER_BELOW_MASK_2; \
float    LAYER_BELOW_MASK_3; \
float    LAYER_BELOW_MASK_4; \
float    LAYER_BELOW_MASK_5; \
float    LAYER_BELOW_MASK_6; \
float    LAYER_BELOW_MASK_7 \

// [[[[[[[[[[[[[[[[[[[ Data Material ]]]]]]]]]]]]]]]]]]] \\

#define SETUP_DATA_FRAGMENT \
vec4    LAYER_BELOW_TEX_0; \
vec4    LAYER_BELOW_TEX_1; \
vec4    LAYER_BELOW_TEX_2; \
vec4    LAYER_BELOW_TEX_3; \
vec4    LAYER_BELOW_TEX_4; \
vec4    LAYER_BELOW_TEX_5; \
vec4    LAYER_BELOW_TEX_6; \
vec4    LAYER_BELOW_TEX_7; \
vec4    LAYER_BELOW_TEX_8; \
vec4    LAYER_BELOW_TEX_9; \
vec4    LAYER_BELOW_TEX_10; \
vec4    LAYER_BELOW_TEX_11; \
vec4    LAYER_BELOW_TEX_12; \
vec4    LAYER_BELOW_TEX_13; \
vec4    LAYER_BELOW_TEX_14; \
vec4    LAYER_BELOW_TEX_15; \
float    LAYER_BELOW_MASK_0; \
float    LAYER_BELOW_MASK_1; \
float    LAYER_BELOW_MASK_2; \
float    LAYER_BELOW_MASK_3; \
float    LAYER_BELOW_MASK_4; \
float    LAYER_BELOW_MASK_5; \
float    LAYER_BELOW_MASK_6; \
float    LAYER_BELOW_MASK_7; \
float    LAYER_BELOW_MASK_8; \
float    LAYER_BELOW_MASK_9; \
float    LAYER_BELOW_MASK_10; \
float    LAYER_BELOW_MASK_11; \
float    LAYER_BELOW_MASK_12; \
float    LAYER_BELOW_MASK_13; \
float    LAYER_BELOW_MASK_14; \
float    LAYER_BELOW_MASK_15; \
vec4    LAYER_OUT_TEX_0; \
vec4    LAYER_OUT_TEX_1; \
vec4    LAYER_OUT_TEX_2; \
vec4    LAYER_OUT_TEX_3; \
vec4    LAYER_OUT_TEX_4; \
vec4    LAYER_OUT_TEX_5; \
vec4    LAYER_OUT_TEX_6; \
vec4    LAYER_OUT_TEX_7; \
vec4    LAYER_OUT_TEX_8; \
vec4    LAYER_OUT_TEX_9; \
vec4    LAYER_OUT_TEX_10; \
vec4    LAYER_OUT_TEX_11; \
vec4    LAYER_OUT_TEX_12; \
vec4    LAYER_OUT_TEX_13; \
vec4    LAYER_OUT_TEX_14; \
vec4    LAYER_OUT_TEX_15; \
float    LAYER_OUT_MASK_0; \
float    LAYER_OUT_MASK_1; \
float    LAYER_OUT_MASK_2; \
float    LAYER_OUT_MASK_3; \
float    LAYER_OUT_MASK_4; \
float    LAYER_OUT_MASK_5; \
float    LAYER_OUT_MASK_6; \
float    LAYER_OUT_MASK_7; \
float    LAYER_OUT_MASK_8; \
float    LAYER_OUT_MASK_9; \
float    LAYER_OUT_MASK_10; \
float    LAYER_OUT_MASK_11; \
float    LAYER_OUT_MASK_12; \
float    LAYER_OUT_MASK_13; \
float    LAYER_OUT_MASK_14; \
float    LAYER_OUT_MASK_15 \

#define SETUP_DATA_VERTEX \
vec4    LAYER_BELOW_TEX_0; \
vec4    LAYER_BELOW_TEX_1; \
vec4    LAYER_BELOW_TEX_2; \
vec4    LAYER_BELOW_TEX_3; \
vec4    LAYER_BELOW_TEX_4; \
vec4    LAYER_BELOW_TEX_5; \
vec4    LAYER_BELOW_TEX_6; \
vec4    LAYER_BELOW_TEX_7; \
float    LAYER_BELOW_MASK_0; \
float    LAYER_BELOW_MASK_1; \
float    LAYER_BELOW_MASK_2; \
float    LAYER_BELOW_MASK_3; \
float    LAYER_BELOW_MASK_4; \
float    LAYER_BELOW_MASK_5; \
float    LAYER_BELOW_MASK_6; \
float    LAYER_BELOW_MASK_7; \
vec4    LAYER_OUT_TEX_0; \
vec4    LAYER_OUT_TEX_1; \
vec4    LAYER_OUT_TEX_2; \
vec4    LAYER_OUT_TEX_3; \
vec4    LAYER_OUT_TEX_4; \
vec4    LAYER_OUT_TEX_5; \
vec4    LAYER_OUT_TEX_6; \
vec4    LAYER_OUT_TEX_7; \
float    LAYER_OUT_MASK_0; \
float    LAYER_OUT_MASK_1; \
float    LAYER_OUT_MASK_2; \
float    LAYER_OUT_MASK_3; \
float    LAYER_OUT_MASK_4; \
float    LAYER_OUT_MASK_5; \
float    LAYER_OUT_MASK_6; \
float    LAYER_OUT_MASK_7 \


struct layerMatFragment{
    vec3    layer_mat_albedo;
    vec3    layer_mat_normal_map;
    float   layer_mat_roughness;
    float   layer_mat_ao;
    float   layer_mat_height;
    float   layer_mat_metallic;
    vec3    layer_mat_emission;
    vec3    layer_mat_bent_normal;
    vec3    layer_mat_mesh_normal_map;
    float   layer_mat_mesh_ao;
    float   layer_mat_mesh_height;
    float   layer_mat_mesh_curvature;
    float   layer_mat_mesh_thickness;
};

struct layerMatVertex{
    vec3    layer_mat_vertex;
    float   layer_mat_height;
};

struct layerDataFragment{
    vec4  layer_data_tex_0;
    vec4  layer_data_tex_1;
    vec4  layer_data_tex_2;
    vec4  layer_data_tex_3;
    vec4  layer_data_tex_4;
    vec4  layer_data_tex_5;
    vec4  layer_data_tex_6;
    vec4  layer_data_tex_7;
    vec4  layer_data_tex_8;
    vec4  layer_data_tex_9;
    vec4  layer_data_tex_10;
    vec4  layer_data_tex_11;
    vec4  layer_data_tex_12;
    vec4  layer_data_tex_13;
    vec4  layer_data_tex_14;
    vec4  layer_data_tex_15;

    float layer_data_mask_0;
    float layer_data_mask_1;
    float layer_data_mask_2;
    float layer_data_mask_3;
    float layer_data_mask_4;
    float layer_data_mask_5;
    float layer_data_mask_6;
    float layer_data_mask_7;
    float layer_data_mask_8;
    float layer_data_mask_9;
    float layer_data_mask_10;
    float layer_data_mask_11;
    float layer_data_mask_12;
    float layer_data_mask_13;
    float layer_data_mask_14;
    float layer_data_mask_15;
};

struct layerDataVertex{
    vec4 layer_data_tex_0;
    vec4 layer_data_tex_1;
    vec4 layer_data_tex_2;
    vec4 layer_data_tex_3;
    vec4 layer_data_tex_4;
    vec4 layer_data_tex_5;
    vec4 layer_data_tex_6;
    vec4 layer_data_tex_7;

    float layer_data_mask_0;
    float layer_data_mask_1;
    float layer_data_mask_2;
    float layer_data_mask_3;
    float layer_data_mask_4;
    float layer_data_mask_5;
    float layer_data_mask_6;
    float layer_data_mask_7;
};

float l_getChannel(vec4 tex, vec2 uv, int ch) {
	if (ch == 0) return tex.r;
	if (ch == 1) return tex.g;
	if (ch == 2) return tex.b;
	return tex.a;
}

vec3 layer_normalCombine(vec3 n1, vec3 n2){
	return vec3(n1.rg + ((n2.rg - 0.5)), n1.z * n2.z);
}