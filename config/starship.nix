{pkgs, ... }:
{
programs.starship = {
    enable = true;
    package = pkgs.starship;
    enableZshIntegration = true;
    settings = {
    add_newline = false;
    c = {
        symbol = " ";
    };
    directory = {
        read_only = " 󰌾";
    };
    docker_context = {
        symbol = " ";
    };
    git_branch = {
        symbol = " ";
    };
    golang = {
        symbol = " ";
    };
    hg_branch = {
        symbol = " ";
    };
    hostname = {
        ssh_symbol = " ";
    };
    lua = {
        symbol = " ";
    };
    memory_usage = {
        symbol = "󰍛 ";
    };
    meson = {
        symbol = "󰔷 ";
    };
    nix_shell = {
        symbol = " ";
    };
    nodejs = {
        symbol = " ";
    };
    ocaml = {
        symbol = " ";
    };
    package = {
        symbol = "󰏗 ";
    };
    python = {
        symbol = " ";
    };
    rust = {
        symbol = " ";
    };
    swift = {
        symbol = " ";
    };
    zig = {
        symbol = " ";
    };
 };
};
}
