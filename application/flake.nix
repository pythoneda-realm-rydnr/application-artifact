{
  description = "Application layer for pythoneda-realm-rydnr";
  inputs = rec {
    nixos.url = "github:NixOS/nixpkgs/nixos-23.05";
    flake-utils.url = "github:numtide/flake-utils/v1.0.0";
    pythoneda-realm-rydnr-events = {
      url = "github:pythoneda-realm-rydnr/events-artifact/0.0.1a1?dir=events";
      inputs.nixos.follows = "nixos";
      inputs.flake-utils.follows = "flake-utils";
      inputs.pythoneda-shared-pythoneda-domain.follows =
        "pythoneda-shared-pythoneda-domain";
    };
    pythoneda-realm-rydnr-infrastructure = {
      url =
        "github:pythoneda-realm-rydnr/infrastructure-artifact/0.0.1a1?dir=infrastructure";
      inputs.nixos.follows = "nixos";
      inputs.flake-utils.follows = "flake-utils";
      inputs.pythoneda-shared-pythoneda-domain.follows =
        "pythoneda-shared-pythoneda-domain";
    };
    pythoneda-shared-artifact-changes-events = {
      url =
        "github:pythoneda-shared-artifact-changes/events-artifact/0.0.1a3?dir=events";
      inputs.nixos.follows = "nixos";
      inputs.flake-utils.follows = "flake-utils";
      inputs.pythoneda-shared-pythoneda-domain.follows =
        "pythoneda-shared-pythoneda-domain";
    };
    pythoneda-shared-pythoneda-domain = {
      url =
        "github:pythoneda-shared-pythoneda/domain-artifact/0.0.1a25?dir=domain";
      inputs.nixos.follows = "nixos";
      inputs.flake-utils.follows = "flake-utils";
    };
    pythoneda-shared-pythoneda-infrastructure = {
      url =
        "github:pythoneda-shared-pythoneda/infrastructure-artifact/0.0.1a13?dir=infrastructure";
      inputs.nixos.follows = "nixos";
      inputs.flake-utils.follows = "flake-utils";
      inputs.pythoneda-shared-pythoneda-domain.follows =
        "pythoneda-shared-pythoneda-domain";
    };
    pythoneda-shared-pythoneda-application = {
      url =
        "github:pythoneda-shared-pythoneda/application-artifact/0.0.1a13?dir=application";
      inputs.nixos.follows = "nixos";
      inputs.flake-utils.follows = "flake-utils";
      inputs.pythoneda-shared-pythoneda-domain.follows =
        "pythoneda-shared-pythoneda-domain";
    };
  };
  outputs = inputs:
    with inputs;
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixos { inherit system; };
        description = "Application layer for pythoneda-realm-rydnr";
        license = pkgs.lib.licenses.gpl3;
        homepage = "https://github.com/pythoneda-realm-rydnr/application";
        maintainers = [ "rydnr <github@acm-sl.org>" ];
        nixpkgsRelease = "nixos-23.05";
        shared = import ./nix/shared.nix;
        pythoneda-realm-rydnr-application-for = { python
          , pythoneda-realm-rydnr-events, pythoneda-realm-rydnr-infrastructure
          , pythoneda-shared-artifact-changes-events
          , pythoneda-shared-pythoneda-domain
          , pythoneda-shared-pythoneda-infrastructure
          , pythoneda-shared-pythoneda-application, version }:
          let
            pname = "pythoneda-realm-rydnr-application";
            pnameWithUnderscores =
              builtins.replaceStrings [ "-" ] [ "_" ] pname;
            pythonpackage = "pythoneda.realm.rydnr.application";
            pythonVersionParts = builtins.splitVersion python.version;
            pythonMajorVersion = builtins.head pythonVersionParts;
            pythonMajorMinorVersion =
              "${pythonMajorVersion}.${builtins.elemAt pythonVersionParts 1}";
            wheelName =
              "${pnameWithUnderscores}-${version}-py${pythonMajorVersion}-none-any.whl";
          in python.pkgs.buildPythonPackage rec {
            inherit pname version;
            projectDir = ./.;
            pyprojectTemplateFile = ./pyprojecttoml.template;
            pyprojectTemplate = pkgs.substituteAll {
              authors = builtins.concatStringsSep ","
                (map (item: ''"${item}"'') maintainers);
              desc = description;
              inherit homepage pname pythonMajorMinorVersion pythonpackage
                version;
              package = builtins.replaceStrings [ "." ] [ "/" ] pythonpackage;
              pythonedaRealmRydnrEventsVersion =
                pythoneda-realm-rydnr-events.version;
              pythonedaRealmRydnrInfrastructureVersion =
                pythoneda-realm-rydnr-infrastructure.version;
              pythonedaSharedArtifactChangesEventsVersion =
                pythoneda-shared-artifact-changes-events.version;
              pythonedaSharedPythonedaDomainVersion =
                pythoneda-shared-pythoneda-domain.version;
              pythonedaSharedPythonedaApplicationVersion =
                pythoneda-shared-pythoneda-application.version;
              pythonedaSharedPythonedaInfrastructureVersion =
                pythoneda-shared-pythoneda-infrastructure.version;
              src = pyprojectTemplateFile;
            };
            src = pkgs.fetchFromGitHub {
              owner = "pythoneda-realm-rydnr";
              repo = "application";
              rev = version;
              sha256 = "sha256-v3E7ObTLwmSd1ElvhFGoRR3LY47LGocyoQX2vEfWku0=";
            };

            format = "pyproject";

            nativeBuildInputs = with python.pkgs; [ pip pkgs.jq poetry-core ];
            propagatedBuildInputs = with python.pkgs; [
              pythoneda-realm-rydnr-events
              pythoneda-shared-artifact-changes-events
              pythoneda-shared-pythoneda-domain
              pythoneda-shared-pythoneda-application
              pythoneda-shared-pythoneda-infrastructure
            ];

            pythonImportsCheck = [ pythonpackage ];

            unpackPhase = ''
              cp -r ${src} .
              sourceRoot=$(ls | grep -v env-vars)
              chmod +w $sourceRoot
              cp ${pyprojectTemplate} $sourceRoot/pyproject.toml
            '';

            postInstall = ''
              mkdir $out/dist
              cp dist/${wheelName} $out/dist
              jq ".url = \"$out/dist/${wheelName}\"" $out/lib/python${pythonMajorMinorVersion}/site-packages/${pnameWithUnderscores}-${version}.dist-info/direct_url.json > temp.json && mv temp.json $out/lib/python${pythonMajorMinorVersion}/site-packages/${pnameWithUnderscores}-${version}.dist-info/direct_url.json
            '';

            meta = with pkgs.lib; {
              inherit description homepage license maintainers;
            };
          };
        pythoneda-realm-rydnr-application-0_0_1a1-for = { python
          , pythoneda-realm-rydnr-events, pythoneda-realm-rydnr-infrastructure
          , pythoneda-shared-artifact-changes-events
          , pythoneda-shared-pythoneda-domain
          , pythoneda-shared-pythoneda-application
          , pythoneda-shared-pythoneda-infrastructure }:
          pythoneda-realm-rydnr-application-for {
            version = "0.0.1a1";
            inherit python pythoneda-realm-rydnr-events
              pythoneda-realm-rydnr-infrastructure
              pythoneda-shared-artifact-changes-events
              pythoneda-shared-pythoneda-domain
              pythoneda-shared-pythoneda-application
              pythoneda-shared-pythoneda-infrastructure;
          };
      in rec {
        packages = rec {
          pythoneda-realm-rydnr-application-0_0_1a1-python38 =
            pythoneda-realm-rydnr-application-0_0_1a1-for {
              python = pkgs.python38;
              pythoneda-realm-rydnr-events =
                pythoneda-realm-rydnr-events.packages.${system}.pythoneda-realm-rydnr-events-latest-python38;
              pythoneda-realm-rydnr-infrastructure =
                pythoneda-realm-rydnr-infrastructure.packages.${system}.pythoneda-realm-rydnr-infrastructure-latest-python38;
              pythoneda-shared-artifact-changes-events =
                pythoneda-shared-artifact-changes-events.packages.${system}.pythoneda-shared-artifact-changes-events-latest-python38;
              pythoneda-shared-pythoneda-domain =
                pythoneda-shared-pythoneda-domain.packages.${system}.pythoneda-shared-pythoneda-domain-latest-python38;
              pythoneda-shared-pythoneda-application =
                pythoneda-shared-pythoneda-application.packages.${system}.pythoneda-shared-pythoneda-application-latest-python38;
              pythoneda-shared-pythoneda-infrastructure =
                pythoneda-shared-pythoneda-infrastructure.packages.${system}.pythoneda-shared-pythoneda-infrastructure-latest-python38;
            };
          pythoneda-realm-rydnr-application-0_0_1a1-python39 =
            pythoneda-realm-rydnr-application-0_0_1a1-for {
              python = pkgs.python39;
              pythoneda-realm-rydnr-events =
                pythoneda-realm-rydnr-events.packages.${system}.pythoneda-realm-rydnr-events-latest-python39;
              pythoneda-realm-rydnr-infrastructure =
                pythoneda-realm-rydnr-infrastructure.packages.${system}.pythoneda-realm-rydnr-infrastructure-latest-python39;
              pythoneda-shared-artifact-changes-events =
                pythoneda-shared-artifact-changes-events.packages.${system}.pythoneda-shared-artifact-changes-events-latest-python39;
              pythoneda-shared-pythoneda-domain =
                pythoneda-shared-pythoneda-domain.packages.${system}.pythoneda-shared-pythoneda-domain-latest-python39;
              pythoneda-shared-pythoneda-application =
                pythoneda-shared-pythoneda-application.packages.${system}.pythoneda-shared-pythoneda-application-latest-python39;
              pythoneda-shared-pythoneda-infrastructure =
                pythoneda-shared-pythoneda-infrastructure.packages.${system}.pythoneda-shared-pythoneda-infrastructure-latest-python39;
            };
          pythoneda-realm-rydnr-application-0_0_1a1-python310 =
            pythoneda-realm-rydnr-application-0_0_1a1-for {
              python = pkgs.python310;
              pythoneda-realm-rydnr-events =
                pythoneda-realm-rydnr-events.packages.${system}.pythoneda-realm-rydnr-events-latest-python310;
              pythoneda-realm-rydnr-infrastructure =
                pythoneda-realm-rydnr-infrastructure.packages.${system}.pythoneda-realm-rydnr-infrastructure-latest-python310;
              pythoneda-shared-artifact-changes-events =
                pythoneda-shared-artifact-changes-events.packages.${system}.pythoneda-shared-artifact-changes-events-latest-python310;
              pythoneda-shared-pythoneda-domain =
                pythoneda-shared-pythoneda-domain.packages.${system}.pythoneda-shared-pythoneda-domain-latest-python310;
              pythoneda-shared-pythoneda-application =
                pythoneda-shared-pythoneda-application.packages.${system}.pythoneda-shared-pythoneda-application-latest-python310;
              pythoneda-shared-pythoneda-infrastructure =
                pythoneda-shared-pythoneda-infrastructure.packages.${system}.pythoneda-shared-pythoneda-infrastructure-latest-python310;
            };
          pythoneda-realm-rydnr-application-latest-python38 =
            pythoneda-realm-rydnr-application-0_0_1a1-python38;
          pythoneda-realm-rydnr-application-latest-python39 =
            pythoneda-realm-rydnr-application-0_0_1a1-python39;
          pythoneda-realm-rydnr-application-latest-python310 =
            pythoneda-realm-rydnr-application-0_0_1a1-python310;
          pythoneda-realm-rydnr-application-latest =
            pythoneda-realm-rydnr-application-latest-python310;
          default = pythoneda-realm-rydnr-application-latest;
        };
        defaultPackage = packages.default;
        devShells = rec {
          pythoneda-realm-rydnr-application-0_0_1a1-python38 =
            shared.devShell-for {
              package =
                packages.pythoneda-realm-rydnr-application-0_0_1a1-python38;
              python = pkgs.python38;
              pythoneda-shared-pythoneda-domain =
                pythoneda-shared-pythoneda-domain.packages.${system}.pythoneda-shared-pythoneda-domain-latest-python38;
              inherit pkgs nixpkgsRelease;
            };
          pythoneda-realm-rydnr-application-0_0_1a1-python39 =
            shared.devShell-for {
              package =
                packages.pythoneda-realm-rydnr-application-0_0_1a1-python39;
              python = pkgs.python39;
              pythoneda-shared-pythoneda-domain =
                pythoneda-shared-pythoneda-domain.packages.${system}.pythoneda-shared-pythoneda-domain-latest-python39;
              inherit pkgs nixpkgsRelease;
            };
          pythoneda-realm-rydnr-application-0_0_1a1-python310 =
            shared.devShell-for {
              package =
                packages.pythoneda-realm-rydnr-application-0_0_1a1-python310;
              python = pkgs.python310;
              pythoneda-shared-pythoneda-domain =
                pythoneda-shared-pythoneda-domain.packages.${system}.pythoneda-shared-pythoneda-domain-latest-python310;
              inherit pkgs nixpkgsRelease;
            };
          pythoneda-realm-rydnr-application-latest-python38 =
            pythoneda-realm-rydnr-application-0_0_1a1-python38;
          pythoneda-realm-rydnr-application-latest-python39 =
            pythoneda-realm-rydnr-application-0_0_1a1-python39;
          pythoneda-realm-rydnr-application-latest-python310 =
            pythoneda-realm-rydnr-application-0_0_1a1-python310;
          pythoneda-realm-rydnr-application-latest =
            pythoneda-realm-rydnr-application-latest-python310;
          default = pythoneda-realm-rydnr-application-latest;

        };
      });
}
