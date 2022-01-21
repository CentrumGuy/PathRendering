//
//  MTLShared.metal
//  PathRendering
//
//  Created by Shahar Ben-Dor on 1/16/22.
//

#include <metal_stdlib>
using namespace metal;


typedef float mtlfloat;
typedef float2 mtlfloat2;
typedef float3 mtlfloat3;
typedef float4 mtlfloat4;

typedef float2x2 mtlfloat2x2;
typedef float2x3 mtlfloat2x3;
typedef float2x4 mtlfloat2x4;

typedef float3x2 mtlfloat3x2;
typedef float3x3 mtlfloat3x3;
typedef float3x4 mtlfloat3x4;

typedef float4x2 mtlfloat4x2;
typedef float4x3 mtlfloat4x3;
typedef float4x4 mtlfloat4x4;

typedef float4 mtlcolor;

struct MTLVertex {
    mtlfloat4 position [[position]];
    mtlcolor color;
};

struct MTLFragment {
    mtlcolor color0 [[color(0)]];
    mtlcolor color1 [[color(1)]];
    mtlcolor color2 [[color(2)]];
};
