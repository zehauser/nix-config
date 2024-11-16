{
  outputs =
    inputs:
    let
      inherit (import ./lib/makeSystem.nix inputs) nixosSystem macosSystem;
    in
    {
      nixosConfigurations = {
        alcedo = nixosSystem "alcedo";
        mergus = nixosSystem "mergus";
      };

      darwinConfigurations = {
        Noctua = macosSystem "Noctua";
        Ciconia = macosSystem "Ciconia";
      };
    };

  inputs = {
    # I haven't really verified this, but the point of this split is supposed to be:
    # - nixos-unstable is the standard rolling-updates channel for NixOS systems
    #   and is a common choice for them (though so are the stable channels!), but
    #   Darwin binaries often won't be cached (and I'll have to build from source
    #   unnecessarily)
    # - nixpkgs-unstable should have the Darwin packages cached
    nixpkgs-nixos.url = "nixpkgs/nixos-unstable";
    nixpkgs-macos.url = "nixpkgs/nixpkgs-unstable";

    # MacOS + NixOS
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs-nixos";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs-nixos";
    };

    # MacOS-only
    homebrew-bundle = {
      url = "github:homebrew/homebrew-bundle";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs-macos";
    };
    nix-homebrew = {
      url = "github:zhaofengli-wip/nix-homebrew";
      inputs.nixpkgs.follows = "nixpkgs-macos";
      inputs.nix-darwin.follows = "nix-darwin";
    };
    nix-vscode-extensions = {
      url = "github:nix-community/nix-vscode-extensions";
    };
    mac-app-util = {
      url = "github:hraban/mac-app-util";
      inputs.nixpkgs.follows = "nixpkgs-macos";
    };

    # NixOS-only
    argon-fan-manager = {
      url = "github:zehauser/argon-fan-manager";
      inputs.nixpkgs.follows = "nixpkgs-nixos";
    };
    impermanence = {
      url = "github:nix-community/impermanence";
    };
    nixos-hardware = {
      url = "github:NixOS/nixos-hardware/master";
    };
    vscode-server = {
      url = "github:nix-community/nixos-vscode-server";
      inputs.nixpkgs.follows = "nixpkgs-nixos";
    };
  };
}
