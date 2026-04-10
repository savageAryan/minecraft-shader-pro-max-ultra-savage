#version 330 compatibility

uniform int renderStage;
uniform float viewHeight;
uniform float viewWidth;
uniform mat4 gbufferModelView;
uniform mat4 gbufferProjectionInverse;
uniform vec3 fogColor;
uniform vec3 skyColor;
uniform vec3 sunPosition; 

in vec4 glcolor;

/* Convert screen to view space */
vec3 screenToView(vec3 screenPos) {
    vec4 ndcPos = vec4(screenPos, 1.0) * 2.0 - 1.0;
    vec4 tmp = gbufferProjectionInverse * ndcPos;
    return tmp.xyz / tmp.w;
}

/* Smooth sky color with horizon blending */
vec3 calcSkyColor(vec3 pos) {
    float up = dot(pos, gbufferModelView[1].xyz);

    vec3 sky = skyColor;
    vec3 fog = fogColor;

    float horizon = smoothstep(-0.2, 0.5, up);

    return mix(fog, sky, horizon);
}

/* RENDERTARGETS: 0 */
out vec4 color;

void main() {

    if (renderStage == MC_RENDER_STAGE_STARS) {
        color = glcolor;
    } else {
        vec3 pos = screenToView(
            vec3(gl_FragCoord.xy / vec2(viewWidth, viewHeight), 1.0)
        );

        vec3 dir = normalize(pos);
        vec3 col = calcSkyColor(dir);

        // =========================
// 🌌 SKY DEPTH LAYER
// =========================

// deeper blue at top
float zenith = pow(max(dir.y, 0.0), 2.0);

// darker upper sky
vec3 deepBlue = vec3(0.05, 0.1, 0.25);

// blend
col = mix(col, deepBlue, zenith * 0.5);

        // 🌙 NIGHT FACTOR
        float night = clamp(-sunPosition.y, 0.0, 1.0);

        // 🌙 MOON (opposite sun)
        vec3 moonDir = normalize(-sunPosition);
        float moon = dot(dir, moonDir);
        moon = pow(max(moon, 0.0), 180.0);

        vec3 moonColor = vec3(0.6, 0.7, 1.0);
        col += moonColor * moon * (1.5 + night);

        // 🌌 STARS
        float starNoise = fract(sin(dot(dir.xy * 500.0, vec2(12.9898,78.233))) * 43758.5453);
        float stars = step(0.997, starNoise);

        col += vec3(1.0) * stars * night;

        // 🌙 Slight night sky boost (IMPORTANT)
        col += vec3(0.05, 0.1, 0.2) * night;

        // ☀️ sun direction
vec3 sunDir = normalize(sunPosition);

// sun disk
float sun = dot(dir, sunDir);
sun = pow(max(sun, 0.0), 400.0);

// glow
float glow = pow(max(sun, 0.0), 6.0);

// color
vec3 sunColor = vec3(1.0, 0.85, 0.6);

// apply
col += sunColor * sun * 3.0;
col += sunColor * glow * 0.5;

// 🌅 sunset factor
float sunHeight = sunDir.y;

// horizon mask (only near horizon)
float horizon = 1.0 - abs(dir.y);

// sunset strength
float sunset = smoothstep(0.2, -0.2, sunHeight) * horizon;

// colors
vec3 orange = vec3(1.0, 0.4, 0.1);
vec3 pink   = vec3(1.0, 0.6, 0.4);

// layered blend
col = mix(col, col * pink, sunset * 0.6);
col = mix(col, col * orange, sunset * 0.5);

        // prevent overexposure
        col = clamp(col, 0.0, 1.0);

        color = vec4(col, 1.0);
    }
}
