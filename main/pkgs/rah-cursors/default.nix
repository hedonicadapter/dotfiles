# rah: custom cursor theme, kept as hyprcursor-util workspace in assets/cursors/rah.
# Builds both formats into one icon dir:
#   - hyprcursor (manifest.hl + .hlc) for Hyprland
#   - XCursor (cursors/ + index.theme) for niri, GTK, Xwayland
# Native PNGs top out at 48px; XCursor gets extra nearest-neighbour upscales so
# large sizes keep pixel look hyprcursor's `resize_algorithm = none` gave.
{
  lib,
  stdenvNoCC,
  hyprcursor,
  xcursorgen,
  imagemagick,
  extraSizes ? [64 96 100 128 200],
}:
stdenvNoCC.mkDerivation {
  pname = "rah-cursors";
  version = "0.1";

  src = ../../assets/cursors/rah;

  nativeBuildInputs = [hyprcursor xcursorgen imagemagick];

  buildPhase = ''
    runHook preBuild

    theme=build/rah
    mkdir -p "$theme/cursors" work

    # hyprcursor: compile workspace -> theme_rah/{manifest.hl,hyprcursors/*.hlc}
    hyprcursor-util --create . --output build
    cp -r build/theme_rah/. "$theme/"

    for dir in hyprcursors/*/; do
      shape=$(basename "$dir")
      meta="$dir/meta.hl"
      hx=$(sed -nE 's/^hotspot_x *= *//p' "$meta")
      hy=$(sed -nE 's/^hotspot_y *= *//p' "$meta")
      cfg="work/$shape.cfg"
      : > "$cfg"

      # define_size = <size>, <file>, <delay ms>  (delay optional)
      sed -nE 's/^define_size *= *//p' "$meta" | tr -d ' ' > "work/$shape.sizes"
      maxsize=$(cut -d, -f1 "work/$shape.sizes" | sort -n | tail -1)

      while IFS=, read -r size file delay; do
        xh=$(awk -v f="$hx" -v s="$size" 'BEGIN{printf "%d", f*s+0.5}')
        yh=$(awk -v f="$hy" -v s="$size" 'BEGIN{printf "%d", f*s+0.5}')
        echo "$size $xh $yh $dir$file ''${delay:-50}" >> "$cfg"
      done < "work/$shape.sizes"

      # Upscale largest native frames, frame order preserved for animations
      for target in ${lib.concatMapStringsSep " " toString extraSizes}; do
        xh=$(awk -v f="$hx" -v s="$target" 'BEGIN{printf "%d", f*s+0.5}')
        yh=$(awk -v f="$hy" -v s="$target" 'BEGIN{printf "%d", f*s+0.5}')
        while IFS=, read -r size file delay; do
          [ "$size" = "$maxsize" ] || continue
          scaled="work/''${file%.png}_$target.png"
          magick "$dir$file" -filter point -resize "''${target}x''${target}!" "PNG32:$scaled"
          echo "$target $xh $yh $scaled ''${delay:-50}" >> "$cfg"
        done < "work/$shape.sizes"
      done

      xcursorgen "$cfg" "$theme/cursors/$shape"

      # Aliases (e.g. left_ptr -> default, arrow)
      sed -nE 's/^define_override *= *//p' "$meta" | tr -d ' ' | while read -r alias; do
        [ -n "$alias" ] && [ ! -e "$theme/cursors/$alias" ] && ln -s "$shape" "$theme/cursors/$alias"
      done
    done

    cat > "$theme/index.theme" <<EOF
    [Icon Theme]
    Name=rah
    Comment=rah cursor theme
    EOF

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/icons
    cp -r build/rah $out/share/icons/rah
    runHook postInstall
  '';

  meta = {
    description = "rah cursor theme (hyprcursor + XCursor)";
    platforms = lib.platforms.linux;
  };
}
