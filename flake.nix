{
  description = "Cursor Editor AppImage wrapped with appimage-run";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      pname = "cursor";
      version = "0.47.0";
      system = "x86_64-linux";
      pkgs = import nixpkgs { 
        inherit system;
        config = {
          allowUnfree = true;
        };
      };
      
      src = pkgs.fetchurl {
        url = "https://downloads.cursor.com/production/client/linux/x64/appimage/Cursor-0.47.0-4a602340d7b014d700647120bae9079607f2ae9b.deb.glibc2.25-x86_64.AppImage";
        hash = "sha256-TR9TX4nZHODPWuIkWEUzger5Lte3G2tQWTE4MaxUn+4=";
      };

      appimageContents = pkgs.appimageTools.extract {
        inherit pname version src;
      };

      cursor = pkgs.appimageTools.wrapType2 {
        inherit pname version src;

        extraInstallCommands = ''
          # Create directories
          mkdir -p $out/share/applications

          # Copy desktop files
          cp ${appimageContents}/usr/share/applications/cursor.desktop $out/share/applications/
          cp ${appimageContents}/usr/share/applications/cursor-url-handler.desktop $out/share/applications/

          # Copy icon
          install -D ${appimageContents}/usr/share/icons/hicolor/512x512/apps/cursor.png $out/share/icons/hicolor/512x512/apps/cursor.png

          # Fix paths in desktop files
          substituteInPlace $out/share/applications/cursor.desktop \
            --replace '/usr/share/cursor/cursor' 'cursor' \
            --replace 'Icon=co.anysphere.cursor' 'Icon=cursor'

          substituteInPlace $out/share/applications/cursor-url-handler.desktop \
            --replace '/usr/share/cursor/cursor' 'cursor' \
            --replace 'Icon=co.anysphere.cursor' 'Icon=cursor'
        '';
      };
      
    in {
      packages.x86_64-linux = {
        inherit cursor;
        default = cursor;
      };
    };
} 