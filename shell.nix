with import <nixpkgs> { };
(let
  python = let
    packageOverrides = self: super: {
      opencv4 = super.opencv4.override {
        enableGtk2 = true; # boolean
        gtk2 = pkgs.gnome2.gtk; # pkgs.gtk2-x11
      };
      #opencv4_ = super.opencv4.overrideAttrs (old: rec { 
      #  gtk2 = pkgs.gtk2 ; # pkgs.gtk2-x11 # pkgs.gnome2.gtk;
      #  # doCheck = false;
      #  });
    };
  in pkgs.python3.override {
    inherit packageOverrides;
    self = python;
  };
in python.withPackages (ps: with ps; [ opencv4 libGL virtualenv ])).env
