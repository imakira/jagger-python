{
  description = "";
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  outputs = { self, nixpkgs }:
    let
      supportedSystems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      forEachSupportedSystem = f: nixpkgs.lib.genAttrs supportedSystems (system: f rec {
        pkgs = import nixpkgs { inherit system; };
        inherit system;
      });
    in
    {
      devShells = forEachSupportedSystem ({ pkgs,  system }:
        {
        default = pkgs.mkShell {
          buildInputs = with pkgs; [
            # putting clang-tools first and clangd works
            # otherwise it can't find stdlib
            clang-tools
            clang
            cmake
            python3Packages.pybind11
            emscripten
          ];
          packages = with pkgs; [
            (python3.withPackages (ps:
              with ps; [ datasets tqdm ]))
          ];
          shellHook = let
            emscripten_include_path = "${pkgs.emscripten}/share/emscripten/cache/sysroot/include/";
          in ''
            export CPLUS_INCLUDE_PATH="''${CPLUS_INCLUDE_PATH:+''${CPLUS_INCLUDE_PATH}:}${emscripten_include_path}"
            '';
        };
      });
    };
}
