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
    const float LUMINANCE_PRESERVATION_FACTOR = 0.0;

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
        // CRT curvature distortion
        vec2 tc = v_texcoord;
        float dx = abs(0.5 - tc.x);
        float dy = abs(0.5 - tc.y);
        dx *= dx;
        dy *= dy;
        tc.x = (tc.x - 0.5) * (1.0 + dy * CURVATURE_STRENGTH) + 0.5;
        tc.y = (tc.y - 0.5) * (1.0 + dx * CURVATURE_STRENGTH) + 0.5;

        // Sample base color with distortion
        vec4 baseColor = texture2D(tex, tc);
        vec3 color = baseColor.rgb;

        // Apply color temperature
        color *= colorTemperatureToRGB(COLOR_TEMPERATURE);

        // Calculate glow from surrounding pixels
        // Calculate glow with better sampling
        vec3 glow = vec3(0.0);
        float samples = 0.0;
        for (float x = -2.0; x <= 2.0; x += 1.0) {
            for (float y = -2.0; y <= 2.0; y += 1.0) {
                vec2 offset = vec2(x, y) * GLOW_RADIUS;
                glow += texture2D(tex, tc + offset).rgb;
                samples += 1.0;
            }
        }
        glow /= samples;

        // Enhanced glow blending (additive + screen)
        vec3 blendedGlow = mix(color, max(color, glow * 1.5), GLOW_STRENGTH);
        color = mix(color, blendedGlow, 0.8);

        // Apply color temperature after glow
        color *= colorTemperatureToRGB(COLOR_TEMPERATURE);

        // Scanlines with gamma correction
        float scanline = 1.0 - abs(sin(tc.y * SCANLINE_FREQUENCY * 3.1415 * 2.0)) * SCANLINE_INTENSITY;
        color = pow(color * scanline, vec3(1.0/1.1));

        // Contrast/brightness with better range control
        color = (color - 0.5) * CONTRAST * 1.1 + 0.5 + BRIGHTNESS * 0.3;

        // Luminance preservation
        #ifdef WITH_QUICK_AND_DIRTY_LUMINANCE_PRESERVATION
        vec3 luminance = vec3(dot(color, vec3(0.2126, 0.7152, 0.0722)));
        color = mix(color, luminance, LUMINANCE_PRESERVATION_FACTOR);
        #endif

        // Clamp and output
        color = clamp(color, 0.0, 2.0); // Allow overbright for glow
        vec4 outCol = (any(greaterThan(tc, vec2(1.0))) || any(lessThan(tc, vec2(0.0))))
            ? vec4(0.0)
            : vec4(color, baseColor.a);

        gl_FragColor = outCol;
    }
  '';
in
  frag
