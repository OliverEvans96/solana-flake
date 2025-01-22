{
  description = "Solana";
  inputs = { nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable"; };
  outputs = inputs:
    with import inputs.nixpkgs { system = "x86_64-linux"; }; rec {
      packages.x86_64-linux.default =
        with import inputs.nixpkgs { system = "x86_64-linux"; };
        let solana-cli = (import ./solana-cli/default.nix) inputs;
        solana-bpf-tools = (import ./solana-bpf-tools/default.nix) inputs;
        cargo-build-bpf = (import ./cargo-build-bpf/default.nix) inputs;
        in stdenv.mkDerivation rec {
          name = "solana-${version}";
          version = "1.23.1";

          phases = [ "installPhase" ];

          installPhase = ''
            mkdir -p $out
            cp -rf ${solana-cli}/* $out
            chmod 0755 -R $out;

            cp -rf ${cargo-build-bpf}/* $out
            chmod 0755 -R $out;

            mkdir -p $out/bin/sdk/bpf
            cp -rf ${solana-bpf-tools}/* $out/bin/sdk/bpf/
            chmod 0755 -R $out;
          '';

          meta = with lib; {
            homepage = "https://github.com/solana-labs";
            platforms = platforms.linux;
          };
        };

      devShells.x86_64-linux.default =
        mkShellNoCC { packages = with packages.x86_64-linux; [ default ]; };
    };
}
