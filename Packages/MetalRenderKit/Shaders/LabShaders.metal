#include <metal_stdlib>
#include <SwiftUI/SwiftUI_Metal.h>
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

[[ stitchable ]] half4 lab_symbol_light_sweep(
    float2 position,
    SwiftUI::Layer layer,
    float2 size,
    float time,
    float cycleDuration,
    float sweepDuration,
    float angle,
    float softness,
    float intensity
) {
    half4 source = layer.sample(position);
    float2 safeSize = max(size, float2(1.0));
    float2 uv = position / safeSize;
    float phase = fmod(max(0.0, time), max(1.0, cycleDuration));
    float progress = clamp(phase / max(0.1, sweepDuration), 0.0, 1.0);
    float active = 1.0 - step(sweepDuration, phase);
    float2 direction = float2(cos(angle), sin(angle));
    float projected = dot(uv - 0.5, direction);
    float center = mix(-0.8, 0.8, progress);
    float band = 1.0 - smoothstep(softness * 0.2, softness, abs(projected - center));
    float light = band * active * intensity;

    half nearbyAlpha = max(
        max(layer.sample(position + float2(5.0, 0.0)).a, layer.sample(position - float2(5.0, 0.0)).a),
        max(layer.sample(position + float2(0.0, 5.0)).a, layer.sample(position - float2(0.0, 5.0)).a)
    );
    half glow = half(light) * max(half(0.0), nearbyAlpha - source.a) * half(0.32);
    half3 litColor = source.rgb + half3(light) * source.a;
    half3 glowColor = half3(0.74, 0.84, 1.0) * glow;
    return half4(litColor + glowColor, max(source.a, glow));
}

struct LabProceduralUniforms {
    float2 resolution;
    float time;
    float motionScale;
    uint seed;
    uint padding;
};

float lab_hash21(float2 p) {
    float3 p3 = fract(float3(p.xyx) * 0.1031);
    p3 += dot(p3, p3.yzx + 33.33);
    return fract((p3.x + p3.y) * p3.z);
}

float2 lab_hash22(float2 p) {
    float n = lab_hash21(p);
    return float2(n, lab_hash21(p + n + 19.19));
}

float lab_value_noise(float2 p) {
    float2 cell = floor(p);
    float2 local = fract(p);
    float2 blend = local * local * (3.0 - 2.0 * local);
    float a = lab_hash21(cell);
    float b = lab_hash21(cell + float2(1.0, 0.0));
    float c = lab_hash21(cell + float2(0.0, 1.0));
    float d = lab_hash21(cell + float2(1.0, 1.0));
    return mix(mix(a, b, blend.x), mix(c, d, blend.x), blend.y);
}

float lab_fbm(float2 p) {
    float value = 0.0;
    float amplitude = 0.52;
    float2x2 rotation = float2x2(float2(0.80, -0.60), float2(0.60, 0.80));
    for (int octave = 0; octave < 5; ++octave) {
        value += lab_value_noise(p) * amplitude;
        p = rotation * p * 2.03 + 11.7;
        amplitude *= 0.5;
    }
    return value;
}

fragment float4 lab_night_sky_fragment(
    LabVertexOut input [[stage_in]],
    constant LabProceduralUniforms &uniforms [[buffer(0)]]
) {
    float2 resolution = max(uniforms.resolution, float2(1.0));
    float2 uv = input.position.xy / resolution;
    float aspect = resolution.x / resolution.y;
    float time = uniforms.time * uniforms.motionScale;
    float seedOffset = float(uniforms.seed & 0xffffu) * 0.00017;

    float3 horizon = float3(0.075, 0.09, 0.21);
    float3 zenith = float3(0.018, 0.025, 0.09);
    float3 color = mix(zenith, horizon, smoothstep(0.0, 1.0, uv.y));

    float2 starScale = float2(112.0 * aspect, 112.0);
    float2 starSpace = uv * starScale;
    float2 starCell = floor(starSpace);
    float2 starLocal = fract(starSpace);
    float density = lab_hash21(starCell + seedOffset);
    float2 starCenter = 0.12 + 0.76 * lab_hash22(starCell + seedOffset + 7.3);
    float starDistance = length(starLocal - starCenter);
    float radius = mix(0.025, 0.075, lab_hash21(starCell + 31.4));
    float starShape = 1.0 - smoothstep(radius * 0.35, radius, starDistance);
    float starExists = step(0.89, density);
    float twinklePhase = lab_hash21(starCell + 71.9) * 6.2831853;
    float twinkleSpeed = mix(0.35, 1.05, lab_hash21(starCell + 14.2));
    float twinkle = 0.72 + 0.28 * sin(twinklePhase + time * twinkleSpeed);
    float warmth = lab_hash21(starCell + 93.7);
    float3 starColor = mix(float3(0.70, 0.79, 1.0), float3(1.0, 0.88, 0.72), warmth * 0.35);
    float stars = starShape * starExists * max(0.3, twinkle);

    float2 cloudPosition = float2(uv.x * aspect, uv.y) * 2.35;
    cloudPosition.x += time * 0.012;
    cloudPosition += seedOffset * 0.31;
    float2 warp = float2(
        lab_fbm(cloudPosition * 0.62 + 4.7),
        lab_fbm(cloudPosition * 0.58 + 17.3)
    ) - 0.5;
    float cloudNoise = lab_fbm(cloudPosition + warp * 0.72);
    float cloudBody = smoothstep(0.54, 0.72, cloudNoise);
    float upperBias = 1.0 - smoothstep(0.08, 0.90, uv.y);
    float cloud = cloudBody * mix(0.42, 1.0, upperBias);

    color += starColor * stars * (1.0 - cloud * 0.72);
    float3 cloudColor = mix(float3(0.13, 0.15, 0.29), float3(0.25, 0.28, 0.43), cloudNoise);
    color = mix(color, cloudColor, cloud * 0.62);

    float2 centered = uv - 0.5;
    centered.x *= aspect;
    float vignette = smoothstep(0.95, 0.25, length(centered));
    color *= mix(0.72, 1.0, vignette);
    return float4(color, 1.0);
}
