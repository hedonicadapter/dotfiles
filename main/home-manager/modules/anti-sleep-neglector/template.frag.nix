{
  temp,
  glowStrength,
  glowRadius,
  scanlineFrequency,
  scanlineIntensity,
  curvatureStrength,
  brightness,
  contrast,
  ...
}: let
  frag = ''
    precision highp float;

    varying vec2 v_texcoord;
    uniform sampler2D tex;

    const float COLOR_TEMPERATURE = ${builtins.toString temp};
    const float TEMPERATURE_STRENGTH = 1.0;

    #define WITH_QUICK_AND_DIRTY_LUMINANCE_PRESERVATION
    const float LUMINANCE_PRESERVATION_FACTOR = 1.0;  // 0.0 to 1.0

    const float GLOW_STRENGTH = ${builtins.toString glowStrength};
    const float GLOW_RADIUS = ${builtins.toString glowRadius};

    const float SCANLINE_FREQUENCY =  ${builtins.toString scanlineFrequency};
    const float SCANLINE_INTENSITY = ${builtins.toString scanlineIntensity};

    const float CURVATURE_STRENGTH = ${builtins.toString curvatureStrength};

    const float BRIGHTNESS = ${builtins.toString brightness};
    const float CONTRAST = ${builtins.toString contrast};

    // Color Temperature to RGB conversion function
    vec3 colorTemperatureToRGB(const in float temperature) {
        mat3 m = (temperature <= 6500.0) ? mat3(vec3(0.0, -2902.1955373783176, -8257.7997278925690),
                                                vec3(0.0, 1669.5803561666639, 2575.2827530017594),
                                                vec3(1.0, 1.3302673723350029, 1.8993753891711275)) :
                                           mat3(vec3(1745.0425298314172, 1216.6168361476490, -8257.7997278925690),
                                                vec3(-2666.3474220535695, -2173.1012343082230, 2575.2827530017594),
                                                vec3(0.55995389139931482, 0.70381203140554553, 1.8993753891711275));
        return mix(
            clamp(vec3(m[0] / (vec3(clamp(temperature, 1000.0, 40000.0)) + m[1]) + m[2]), vec3(0.0), vec3(1.0)),
            vec3(1.0),
            smoothstep(1000.0, 0.0, temperature)
        );
    }

    void main() {
        // CRT-style distortion
        vec2 tc = vec2(v_texcoord.x, v_texcoord.y);

        // Distance from the center
        float dx = abs(0.5 - tc.x);
        float dy = abs(0.5 - tc.y);

        // Square it to smooth the edges
        dx *= dx;
        dy *= dy;

        tc.x -= 0.5;
        tc.x *= 1.0 + (dy * CURVATURE_STRENGTH);
        tc.x += 0.5;

        tc.y -= 0.5;
        tc.y *= 1.0 + (dx * CURVATURE_STRENGTH);
        tc.y += 0.5;

        // Sample texture with distorted coordinates
        vec4 pixColor = texture2D(tex, vec2(tc.x, tc.y));

        // RGB extraction
        vec3 color = vec3(pixColor[0], pixColor[1], pixColor[2]);

        // Apply contrast
        color = (color - 0.5) * CONTRAST + 0.5;

        // Apply brightness
        color += vec3(BRIGHTNESS);

        // Luminance preservation (optional)
        #ifdef WITH_QUICK_AND_DIRTY_LUMINANCE_PRESERVATION
        color *= mix(1.0,
                     dot(color, vec3(0.2126, 0.7152, 0.0722)) / max(dot(color, vec3(0.2126, 0.7152, 0.0722)), 1e-5),
                     LUMINANCE_PRESERVATION_FACTOR);
        #endif

        // Apply color temperature
        color = mix(color, color * colorTemperatureToRGB(COLOR_TEMPERATURE), TEMPERATURE_STRENGTH);

        // Add glow effect
        vec3 glow = vec3(0.0);
        for (float x = -GLOW_RADIUS; x <= GLOW_RADIUS; x += GLOW_RADIUS / 2.0) {
            for (float y = -GLOW_RADIUS; y <= GLOW_RADIUS; y += GLOW_RADIUS / 2.0) {
                glow += texture2D(tex, tc + vec2(x, y)).rgb;
            }
        }
        glow = glow / 25.0; // Normalize glow intensity
        color += glow * GLOW_STRENGTH;

        // Add scanline effect
        color.rgb += sin(tc.y * SCANLINE_FREQUENCY) * SCANLINE_INTENSITY;

        // Cutoff for out-of-bounds coordinates
        vec4 outCol = (tc.y > 1.0 || tc.x < 0.0 || tc.x > 1.0 || tc.y < 0.0)
            ? vec4(0.0)
            : vec4(color, pixColor[3]);

        gl_FragColor = outCol;
    }
  '';
in
  frag
