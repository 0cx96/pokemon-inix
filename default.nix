{ pkgs ? import <nixpkgs> {} }:
let
    lib = pkgs.lib;
    pythonWithDeps = pkgs.python3.withPackages (ps: with ps; [
        aiohappyeyeballs
        aiohttp
        aiosignal
        "async-timeout"
        attrs
        frozenlist
        idna
        "markdown-it-py"
        mdurl
        multidict
        pillow
        propcache
        pygments
        "python-slugify"
        rich
        "text-unidecode"
        "typing-extensions"
        yarl
    ]);

    pokemon-icons = pkgs.stdenv.mkDerivation {
        pname = "pokemon-icons";
        version = "1.1.0";

        outputHashMode = "recursive";
        outputHashAlgo = "sha256";
        outputHash = "sha256-Hnstruc0cI8+moEnBQsbed0+Zw3OGSRXql54uHbJ4pE=";

        src = lib.fileset.toSource {
            root = ./.;
            fileset = lib.fileset.unions [
                ./setup_icons.py
                ./bin/__init__.py
                ./bin/converter.py
            ];
        };

        buildInputs = [
            pythonWithDeps
            pkgs.cacert
            pkgs.optipng
        ];

        buildPhase = ''
            export POKEMON_INIX_DATA=$TMPDIR

            mkdir -p $POKEMON_INIX_DATA/pokemon-icons/normal
            mkdir -p $POKEMON_INIX_DATA/pokemon-icons/shiny

            python3 setup_icons.py

            find $POKEMON_INIX_DATA/pokemon-icons -type f -exec sha256sum {} + | sort | sha256sum
            find $POKEMON_INIX_DATA/pokemon-icons -type f | wc -l
        '';

        installPhase = ''
            mkdir -p $out
            cp -r $POKEMON_INIX_DATA/pokemon-icons $out
        '';

    };

    pokemon-bin = pkgs.rustPlatform.buildRustPackage {
        pname = "pokemon-inix-bin";
        version = "1.2.0";

        src = lib.fileset.toSource {
            root = ./.;
            fileset = lib.fileset.unions [
                ./Cargo.toml
                ./Cargo.lock
                ./src
            ];
        };

        cargoLock = {
            lockFile = ./Cargo.lock;
        };

        nativeBuildInputs = [
            pkgs.makeWrapper
        ];

        # We keep standard buildPhase and installPhase for buildRustPackage
        # providing checking that default cargo behavior works.
        # If the custom buildPhase passed previously was essential, we might need it back.
        # But for standard rust bin project, defaults are usually fine.
    };

    pokemon-inix = pkgs.stdenv.mkDerivation {
        pname = "pokemon-inix";
        version = "1.2.0";

        # Trivial builder to assemble the result
        phases = [ "installPhase" "fixupPhase" ];

        nativeBuildInputs = [ pkgs.makeWrapper ];

        installPhase = ''
            mkdir -p $out/bin
            cp ${pokemon-bin}/bin/pokemon-inix $out/bin

            mkdir -p $out/share/pokemon-inix
            cp -r ${./bin}/* $out/share/pokemon-inix
            chmod -R +w $out/share/pokemon-inix

            cp -r ${pokemon-icons}/pokemon-icons $out/share/pokemon-inix

            wrapProgram $out/bin/pokemon-inix \
                --set POKEMON_INIX_DATA $out/share/pokemon-inix \
                --prefix PATH : ${lib.makeBinPath [ pkgs.nvchecker pkgs.nix ]}
        '';
    };
in
{
    inherit pokemon-icons pokemon-bin pokemon-inix;

    defaultPackages = pokemon-inix;
}

