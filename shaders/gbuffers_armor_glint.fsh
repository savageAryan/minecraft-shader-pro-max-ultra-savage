#version 330 compatibility

precision highp float;

uniform sampler2D lightmap;
uniform sampler2D gtexture;

uniform float alphaTestRef = 0.1;

in vec2 lmcoord;
in vec2 texcoord;
in vec4 glcolor;

/* RENDERTARGETS: 0 */
out vec4 color;

void main() {
    vec4 tex = texture(gtexture, texcoord) * glcolor;
    tex *= texture(lightmap, lmcoord);

    if (tex.a < alphaTestRef) {
        discard;
    }

    vec3 col = tex.rgb;

    // =========================
    // ✨ ARMOR SHINE
    // =========================

    // moving shine effect
    float shine = sin(texcoord.x * 40.0 + texcoord.y * 40.0);

    shine = pow(max(shine, 0.0), 10.0);

    vec3 shineColor = vec3(1.0, 0.9, 0.7);

    col += shineColor * shine * 0.8;

    color = vec4(col, tex.a);
}
