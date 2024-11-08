let
  nixpkgs = builtins.fetchTarball {
    # url = "https://github.com/NixOS/nixpkgs/archive/refs/tags/24.05.tar.gz";
    # sha256 = "sha256:1lr1h35prqkd1mkmzriwlpvxcb34kmhc9dnr48gkm8hh089hifmx";
    url = "https://github.com/NixOS/nixpkgs/archive/refs/tags/23.11.tar.gz";
    sha256 = "sha256:1ndiv385w1qyb3b18vw13991fzb9wg4cl21wglk89grsfsnra41k";
  };
in
  (import nixpkgs { system = "x86_64-linux"; }).pkgs
