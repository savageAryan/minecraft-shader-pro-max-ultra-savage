#version 330 compatibility

uniform vec3 sunPosition;
uniform vec3 skyColor;
uniform float worldTime;
uniform sampler2D lightmap;
uniform sampler2D gtexture;

uniform float alphaTestRef = 0.1;

in vec2 lmcoord;
in vec2 texcoord;
in vec4 glcolor;

/* RENDERTARGETS: 0 */
out vec4 color;

void main() {
    // 🎨 Base texture
    vec4 tex = texture(gtexture, texcoord) * glcolor;
    tex *= texture(lightmap, lmcoord);

    if (tex.a < alphaTestRef) {
        discard;
    }

    vec3 col = tex.rgb;

   // ☀️ fake normal (stable)
vec3 n = vec3(0.0, 1.0, 0.0);

// 🌞 sun direction
vec3 sunDir = normalize(sunPosition);

// 🌞 base light
float light = dot(n, sunDir);
light = clamp(light * 0.6 + 0.4, 0.0, 1.0);

// 🌙 night factor
float nightFactor = clamp(-sunDir.y, 0.0, 1.0);

// 🌫️ ambient (dynamic)
float ambient = mix(0.45, 0.6, nightFactor);

// apply base light
col *= (light + ambient);

// 🌙 moonlight boost
col += vec3(0.25, 0.35, 0.55) * nightFactor * 0.4;


// 🌇 cinematic sunset
float sunHeight = sunDir.y;

// colors
vec3 sunsetWarm = vec3(1.0, 0.45, 0.15);
vec3 sunsetSoft = vec3(1.0, 0.7, 0.4);

// blend strength
float sunset = smoothstep(0.2, -0.2, sunHeight);

// apply layered tint
col = mix(col, col * sunsetSoft, sunset * 0.3);
col = mix(col, col * sunsetWarm, sunset * 0.2);

  col = pow(col, vec3(0.95));


    // 🔚 output
    color = vec4(col, tex.a);
}
