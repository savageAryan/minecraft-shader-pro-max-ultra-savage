#version 330 core

uniform sampler2D colortex0;
precision highp float;
uniform vec3 sunPosition;
in vec2 texcoord;
out vec4 color;

void main() {
    vec2 uv = texcoord;
    vec3 col = texture(colortex0, uv).rgb;

    // =========================
    // ☀️ BRIGHTNESS
    // =========================
    float brightness = dot(col, vec3(0.299, 0.587, 0.114));

    // =========================
    // ☁️ BLOOM (controlled)
    // =========================
    vec3 blur = vec3(0.0);
    float offset = 0.002;

    blur += texture(colortex0, uv + vec2( offset,  0.0)).rgb;
    blur += texture(colortex0, uv + vec2(-offset,  0.0)).rgb;
    blur += texture(colortex0, uv + vec2( 0.0,  offset)).rgb;
    blur += texture(colortex0, uv + vec2( 0.0, -offset)).rgb;

    blur *= 0.25;

    float bloomMask = smoothstep(0.7, 1.0, brightness);
    col += blur * bloomMask * 0.6;

    // =========================
// ✨ HIGHLIGHT BOOST
// =========================

float highlight = smoothstep(0.6, 1.0, brightness);
col += highlight * 0.15;

    // =========================
    // 🌫️ FOG
    // =========================
 
// =========================
// 🌫️ FIXED FOG (no greying)
// =========================

// fake distance
float dist = 1.0 - uv.y;
dist += (1.0 - brightness) * 0.2;

// smoother curve
float fog = exp(-dist * 1.5);
fog = clamp(fog, 0.0, 1.0);

// softer fog color (LESS grey)
vec3 fogColor = vec3(0.65, 0.75, 0.9);

// IMPORTANT: correct blending direction
col = mix(col, fogColor, (1.0 - fog) * 0.4);
   // =========================
// 🌑 CRISP → SOFT SHADOWS
// =========================

float shadowStart = 0.25;
float shadowEnd = 0.65;

float shadowMask = 1.0 - smoothstep(shadowStart, shadowEnd, brightness);

// sharper shadows
float sharp = pow(shadowMask, 1.5);

// apply
col *= mix(1.0, 0.5, sharp);

    // =========================
// ☀️ SUN DIRECTION LIGHTING
// =========================

// fake sun direction (top-right)
vec3 sunDir = normalize(vec3(0.5, 1.0, 0.3));

// approximate surface normal (screen-based fake)
vec3 normal = normalize(vec3(0.0, 1.0, 0.0));

// lighting strength
float NdotL = max(dot(normal, sunDir), 0.0);

// apply lighting
col *= 0.6 + NdotL * 0.6;

    // =========================
    // 🎨 FINAL BALANCE
    // =========================

// slight contrast boost
col = pow(col, vec3(0.92));

// prevent over-darkening
col *= 1.08;

// =========================
// ☀️ IMPROVED GOD RAYS
// =========================

// project sun direction to screen space (approx)
vec2 lightPos = vec2(
    0.5 + sunPosition.x * 0.3,
    0.5 - sunPosition.y * 0.3
);

// direction from pixel to sun
vec2 delta = uv - lightPos;

float rays = 0.0;

// fewer samples = faster 
for (int i = 0; i < 6; i++) {
    float scale = float(i) * 0.03;
    vec2 sampleUV = uv - delta * scale;
    rays += texture(colortex0, sampleUV).r;
}

rays /= 6.0;

// only near sun
float sunMask = smoothstep(0.2, 0.0, length(uv - lightPos));

// only bright areas
float rayMask = smoothstep(0.6, 1.0, brightness);

// apply
col += vec3(1.0, 0.9, 0.7) * rays * rayMask * sunMask * 0.7;

// =========================
// 🎬 CINEMATIC TONE
// =========================

// slight warm tint in highlights
float warm = smoothstep(0.6, 1.0, brightness);
col += vec3(0.05, 0.03, 0.0) * warm;

// slight cool tint in shadows
float dark = smoothstep(0.5, 0.0, brightness);
col += vec3(0.0, 0.02, 0.05) * dark;

    color = vec4(col, 1.0);
}
