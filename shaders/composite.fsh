#version 330 core

uniform sampler2D colortex0;

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
    col += blur * bloomMask * 1.2;

    // =========================
    // 🌫️ FOG
    // =========================
    float fog = smoothstep(0.4, 1.0, uv.y);
    vec3 fogColor = vec3(0.7, 0.8, 1.0);
    col = mix(col, fogColor, fog * 0.5);

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
    col *= 0.9;
    col = pow(col, vec3(1.0));

    color = vec4(col, 1.0);
}
