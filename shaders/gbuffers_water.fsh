#version 330 compatibility

uniform float viewHeight;
uniform float viewWidth;
uniform float frameTimeCounter;
uniform vec3 sunPosition;
uniform vec3 skyColor; // 🔥 IMPORTANT (matches sky)

in vec2 texcoord;

/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 color;

/* 🌊 Smooth waves */
float wave(vec2 uv, float t) {
    vec2 p = gl_FragCoord.xy / vec2(viewWidth, viewHeight);

    float w = 0.0;
    w += sin(p.x * 8.0 + t * 1.2) * 0.01;
    w += sin(p.y * 10.0 + t * 1.0) * 0.01;
    w += sin((p.x + p.y) * 12.0 + t * 1.5) * 0.008;

    return w;
}

/* ✨ sparkles */
float sparkle(vec2 uv, float t) {
    float s = sin(uv.x * 60.0 + t * 4.0) *
              sin(uv.y * 60.0 + t * 4.0);
    return pow(max(s, 0.0), 15.0);
}

void main() {
    vec2 uv = texcoord;
    float t = frameTimeCounter;

    // 🌊 Waves
    float w = wave(uv, t);
    uv += vec2(w, w);

    // 💧 BRIGHT water colors (pool style)
    vec3 shallow = vec3(0.4, 0.75, 0.9);
    vec3 deep = vec3(0.1, 0.4, 0.7);

    float depth = smoothstep(0.1, 1.0, uv.y);
    vec3 waterColor = mix(shallow, deep, depth);

    // 🌞 SKY LIGHTING MATCH
    waterColor = mix(waterColor, skyColor, 0.3);

    // 🌞 day/night factor
    float dayFactor = clamp(sunPosition.y * 0.5 + 0.5, 0.0, 1.0);

    // 🌌 FINAL SKY REFLECTION (IMPROVED)
    vec3 nightSky = vec3(0.05, 0.1, 0.2);
    vec3 skyMix = mix(nightSky, skyColor, dayFactor);

    float fresnel = pow(1.0 - uv.y, 2.0);
    waterColor += skyMix * fresnel * 0.9;

    // ✨ sparkles
    float spark = sparkle(uv, t);
    waterColor += vec3(1.0, 0.9, 0.7) * spark * 0.5;

    // 💡 underwater brightness (day/night balanced)
    waterColor += mix(
        vec3(0.05, 0.1, 0.2),
        vec3(0.15, 0.25, 0.3),
        dayFactor
    );

    // ☀️ SUN REFLECTION (NEW - STRONGER + CLEAN)
    float sunDot = dot(normalize(vec3(uv, 1.0)), normalize(sunPosition));
    sunDot = pow(max(sunDot, 0.0), 50.0);
    waterColor += vec3(1.0, 0.9, 0.7) * sunDot * 0.6;

    // 🌙 NIGHT WATER GLOW (NEW)
    float night = clamp(-sunPosition.y, 0.0, 1.0);
    waterColor += vec3(0.05, 0.1, 0.2) * night * 0.5;

    // 🌫️ LIGHT underwater fog
    float fog = smoothstep(0.3, 1.0, depth);
    waterColor = mix(waterColor, vec3(0.2, 0.5, 0.7), fog * 0.2);

    // 💡 EXTRA LIGHT PENETRATION
    waterColor += vec3(0.1, 0.2, 0.25);

    // 💧 Transparency
    float alpha = mix(0.5, 0.8, depth);

    color = vec4(waterColor, alpha);
}
