//
//  MTLPathRenderer.metal
//  PathRendering
//
//  Created by Shahar Ben-Dor on 1/16/22.
//

#include <metal_stdlib>
#include "MTLShared.metal"
using namespace metal;


// Set DEBUG_MODE to true to test the app on iOS. This will show you the expected output.
#define DEBUG_MODE false


constant mtlfloat4x4 bezierMatrix = mtlfloat4x4(-1, 3,-3,1,
                                                 3,-6, 3,0,
                                                -3, 3, 0,0,
                                                 1, 0, 0,0);


vertex MTLVertex bezier_fill_vertex(constant mtlfloat4x2 *segmentArray [[buffer(0)]],
                                    constant uint *subpathIndexArray [[buffer(1)]],
                                    constant uint& triangleCount [[buffer(2)]],
                                    constant mtlcolor& fillColor [[buffer(3)]],
                                    uint vertexId [[vertex_id]],
                                    uint instanceId [[instance_id]]) {
    mtlfloat4x2 segment = vertexId == 0 ? segmentArray[subpathIndexArray[instanceId]] : segmentArray[instanceId];
    
    mtlfloat u = select(max((mtlfloat) vertexId - 1, 0.0f) / ((mtlfloat) triangleCount), ((mtlfloat) vertexId) / ((mtlfloat) triangleCount + 1), instanceId == subpathIndexArray[instanceId]);
    mtlfloat u2 = u*u;
    mtlfloat u3 = u2*u;
    
    mtlfloat4 uVector = mtlfloat4(u3,u2,u,1);
    mtlfloat4 location = mtlfloat4(segment*bezierMatrix*uVector, 0, 1);
    
    return MTLVertex {
        .position = location,
        .color = fillColor
    };
}



#if DEBUG_MODE
fragment MTLFragment bezier_fill_fragment(MTLVertex vertexIn [[stage_in]],
                                          mtlcolor color0 [[color(0), raster_order_group(0)]],
                                          mtlcolor color1 [[color(1), raster_order_group(0)]],
                                          mtlcolor color2 [[color(2), raster_order_group(0)]]) {

    mtlcolor source = vertexIn.color;
    mtlcolor outColor0 = color0;
    mtlcolor outColor1 = color1;
    mtlcolor outColor2 = color2;

    if (color2.a == 0 && !color1.a) outColor2 = color0;
    if (color1.a == 0) {
        mtlcolor destination = color2.a <= 0 ? color0 : color2;
        mtlcolor mixedColor = source.a*(source - destination) + destination;
        mixedColor.a = 1 - (1-destination.a)*(1-source.a);

        outColor0 = mixedColor;
        outColor1 = 1;
    } else {
        outColor0 = color2;
        outColor1 = 0;
    }

    return MTLFragment {
        .color0 = outColor0,
        .color1 = outColor1,
        .color2 = outColor2
    };
}
#else
fragment MTLFragment bezier_fill_fragment(MTLVertex vertexIn [[stage_in]],
                                          texture2d_ms<float, access::read> texture0 [[texture(0), raster_order_group(0)]],
                                          texture2d_ms<float, access::read> texture1 [[texture(1), raster_order_group(0)]],
                                          texture2d_ms<float, access::read> texture2 [[texture(2), raster_order_group(0)]],
                                          uint sid [[sample_id]]) {
    uint2 coord = uint2(vertexIn.position.xy);
    mtlcolor source = vertexIn.color;
    mtlcolor color0 = texture0.read(coord, sid);
    mtlcolor color1 = texture1.read(coord, sid);
    mtlcolor color2 = texture2.read(coord, sid);

    mtlcolor outColor0 = color0;
    mtlcolor outColor1 = color1;
    mtlcolor outColor2 = color2;

    if (color2.a == 0 && !color1.a) outColor2 = color0;
    if (color1.a == 0) {
        mtlcolor destination = color2.a <= 0 ? color0 : color2;
        mtlcolor mixedColor = source.a*(source - destination) + destination;
        mixedColor.a = 1 - (1-destination.a)*(1-source.a);

        outColor0 = mixedColor;
        outColor1 = 1;
    } else {
        outColor0 = color2;
        outColor1 = 0;
    }

    return MTLFragment {
        .color0 = outColor0,
        .color1 = outColor1,
        .color2 = outColor2
    };
}
#endif

