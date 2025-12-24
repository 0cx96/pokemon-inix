{ pkgs ? import <nixpkgs> {} }:

let
  pythonWithDeps = pkgs.python3.withPackages (ps: with ps; [
    aiohappyeyeballs
    aiohttp
    aiosignal
    async-timeout
    attrs
    frozenlist
    idna
    markdown-it-py
    mdurl
    multidict
    pillow
    propcache
    pygments
    python-slugify
    rich
    text-unidecode
    typing-extensions
    yarl
  ]);
in
pkgs.mkShell {
  buildInputs = with pkgs; [
    # Rust
    rustc
    cargo
    rustfmt
    clippy

    # Python
    pythonWithDeps

    # System Dependencies
    pkg-config
    openssl
    optipng
    cacert
  ];

  shellHook = ''
    export POKEMON_ICAT_DATA="$(pwd)/bin"
    echo "Welcome to the pokemon-inix development shell!"
    echo "Rust version: $(rustc --version)"
    echo "Python version: $(python3 --version)"
  '';
}
