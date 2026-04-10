#version 330 compatibility

precision highp float;

uniform sampler2D lightmap;
uniform sampler2D gtexture;
uniform vec4 entityColor;

uniform float alphaTestRef = 0.1;

in vec2 lmcoord;
in vec2 texcoord;
in vec4 glcolor;

/* RENDERTARGETS: 0 */
out vec4 color;

void main() {
    vec4 tex = texture(gtexture, texcoord) * glcolor;
    tex.rgb = mix(tex.rgb, entityColor.rgb, entityColor.a);
    tex *= texture(lightmap, lmcoord);

    if (tex.a < alphaTestRef) {
        discard;
    }

    vec3 col = tex.rgb;

    // =========================
    // 🔴 EDGE OUTLINE
    // =========================

    float offset = 0.002;

    float center = texture(gtexture, texcoord).a;
    float up    = texture(gtexture, texcoord + vec2(0.0, offset)).a;
    float down  = texture(gtexture, texcoord - vec2(0.0, offset)).a;
    float left  = texture(gtexture, texcoord - vec2(offset, 0.0)).a;
    float right = texture(gtexture, texcoord + vec2(offset, 0.0)).a;

    float edge = abs(center - up) + abs(center - down) +
                 abs(center - left) + abs(center - right);

    edge = clamp(edge * 4.0, 0.0, 1.0);

    vec3 outlineColor = vec3(1.0, 0.1, 0.1);

    col += outlineColor * edge * 0.9;

    color = vec4(col, tex.a);
}
