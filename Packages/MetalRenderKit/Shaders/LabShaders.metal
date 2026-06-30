#include <metal_stdlib>
using namespace metal;

struct LabVertexOut {
    float4 position [[position]];
    float4 color;
    float pointSize [[point_size]];
};

vertex LabVertexOut lab_triangle_vertex(uint vertexID [[vertex_id]]) {
    const float2 positions[] = {
        float2(0.0, 0.72),
        float2(-0.68, -0.55),
        float2(0.68, -0.55),
    };
    const float4 colors[] = {
        float4(0.25, 0.85, 1.0, 1.0),
        float4(0.75, 0.25, 1.0, 1.0),
        float4(1.0, 0.35, 0.45, 1.0),
    };

    LabVertexOut output;
    output.position = float4(positions[vertexID], 0.0, 1.0);
    output.color = colors[vertexID];
    output.pointSize = 1.0;
    return output;
}

fragment float4 lab_vertex_color_fragment(LabVertexOut input [[stage_in]]) {
    return input.color;
}

float lab_hash(uint value) {
    value = (value ^ 61u) ^ (value >> 16u);
    value *= 9u;
    value ^= value >> 4u;
    value *= 0x27d4eb2du;
    value ^= value >> 15u;
    return float(value & 0x00ffffffu) / float(0x01000000u);
}

vertex LabVertexOut lab_particle_vertex(
    uint vertexID [[vertex_id]],
    constant float &time [[buffer(0)]]
) {
    float seed = lab_hash(vertexID);
    float ring = 0.12 + 0.76 * lab_hash(vertexID * 13u + 7u);
    float angle = seed * 6.2831853 + time * (0.2 + 0.8 * lab_hash(vertexID + 31u));
    float pulse = 0.04 * sin(time * 2.0 + seed * 18.0);

    LabVertexOut output;
    output.position = float4(
        cos(angle) * (ring + pulse),
        sin(angle) * (ring + pulse),
        0.0,
        1.0
    );
    output.color = float4(0.2 + seed, 0.35 + 0.55 * (1.0 - seed), 1.0, 0.9);
    output.pointSize = 2.5 + 5.0 * lab_hash(vertexID * 5u);
    return output;
}

fragment float4 lab_particle_fragment(
    LabVertexOut input [[stage_in]],
    float2 pointCoord [[point_coord]]
) {
    float2 centered = pointCoord - 0.5;
    float alpha = smoothstep(0.5, 0.08, length(centered));
    return float4(input.color.rgb, input.color.a * alpha);
}

vertex LabVertexOut lab_fullscreen_vertex(uint vertexID [[vertex_id]]) {
    const float2 positions[] = {
        float2(-1.0, -1.0),
        float2(3.0, -1.0),
        float2(-1.0, 3.0),
    };
    LabVertexOut output;
    output.position = float4(positions[vertexID], 0.0, 1.0);
    output.color = float4(1.0);
    output.pointSize = 1.0;
    return output;
}

fragment float4 lab_manual_layer_fragment(
    LabVertexOut input [[stage_in]],
    constant float &time [[buffer(0)]]
) {
    float2 uv = input.position.xy * 0.0025;
    float wave = 0.5 + 0.5 * sin(time + uv.x * 6.0 + uv.y * 4.0);
    return float4(0.08 + wave * 0.18, 0.18 + wave * 0.35, 0.55 + wave * 0.4, 1.0);
}
