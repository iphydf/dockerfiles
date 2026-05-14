let
  nixpkgs = builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/549bd84d6279f9852cae6225e372cc67fb91a4c1.tar.gz";
    sha256 = "sha256:0dchsfq8czjg8iwr60fxmqnglllchcy64wp60b8wx4wd9mwn0rw4";
  };
in
(import nixpkgs { system = "x86_64-linux"; }).pkgs
