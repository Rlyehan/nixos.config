{ pkgs, ... }:
{
  home.packages = [ pkgs.zed-editor ];

  home.file.".config/zed/settings.json".text = builtins.toJSON {
    # Appearance
    theme = {
      mode = "dark";
      dark = "Catppuccin Mocha";
      light = "Catppuccin Latte";
    };
    ui_font_size = 18;
    buffer_font_size = 17;
    buffer_font_family = "GeistMono Nerd Font Mono";
    ui_font_family = "GeistMono Nerd Font Mono";

    # Vim mode
    vim_mode = true;
    relative_line_numbers = true;

    # Editor behavior
    tab_size = 2;
    format_on_save = "on";
    autosave = { after_delay = { milliseconds = 1000; }; };
    soft_wrap = "editor_width";
    show_whitespaces = "selection";
    inlay_hints = { enabled = true; };
    scroll_beyond_last_line = "one_page";

    # Terminal
    terminal = {
      font_size = 15;
      font_family = "GeistMono Nerd Font Mono";
      shell = { program = "zsh"; };
    };

    # Panel layout
    project_panel = { dock = "left"; };
    outline_panel = { dock = "left"; };
    collaboration_panel = { dock = "left"; };
    git_panel = { dock = "left"; };
    agent = { dock = "right"; };

    # LSP configuration
    languages = {
      Python = {
        language_servers = [ "pyright" "ruff" ];
        format_on_save = { external = { command = "ruff"; arguments = [ "format" "--stdin-filename" "{buffer_path}" "-" ]; }; };
        formatter = { external = { command = "ruff"; arguments = [ "format" "--stdin-filename" "{buffer_path}" "-" ]; }; };
      };
      Go = {
        language_servers = [ "gopls" ];
        format_on_save = "on";
        formatter = "language_server";
      };
      Rust = {
        language_servers = [ "rust-analyzer" ];
        format_on_save = "on";
        formatter = "language_server";
      };
      TypeScript = {
        language_servers = [ "typescript-language-server" ];
        format_on_save = "on";
        formatter = "language_server";
      };
      TSX = {
        language_servers = [ "typescript-language-server" ];
        format_on_save = "on";
        formatter = "language_server";
      };
      SQL = {
        language_servers = [ "sqls" ];
      };
      Nix = {
        language_servers = [ "nil" ];
        formatter = { external = { command = "nixfmt"; arguments = [ ]; }; };
      };
    };

    lsp = {
      rust-analyzer = {
        initialization_options = {
          check = { command = "clippy"; };
          cargo = { allFeatures = true; };
        };
      };
      pyright = {
        settings = {
          python = { analysis = { typeCheckingMode = "basic"; }; };
        };
      };
    };

    # Kiro agent server
    agent_servers = {
      "Kiro Agent" = {
        type = "custom";
        command = "/etc/profiles/per-user/max/bin/kiro-cli";
        args = [ "acp" ];
        env = { };
      };
    };

    # File associations
    file_types = {
      JSON = [ "*.tfstate" "*.tfvars.json" ];
    };

    # Telemetry
    telemetry = {
      metrics = false;
      diagnostics = false;
    };
  };

  home.file.".config/zed/keymap.json".text = builtins.toJSON [
    {
      context = "Workspace";
      bindings = {
        "ctrl-shift-a" = "agent::ToggleFocus"; # Quick agent chat toggle
        "ctrl-shift-e" = "workspace::ToggleLeftDock";
        "ctrl-shift-t" = "workspace::ToggleBottomDock"; # Terminal
        "ctrl-p" = "file_finder::Toggle";
        "ctrl-shift-p" = "command_palette::Toggle";
        "ctrl-\\" = "workspace::ToggleRightDock";
      };
    }
    {
      context = "Editor && vim_mode == normal";
      bindings = {
        "space f" = "file_finder::Toggle";
        "space p" = "command_palette::Toggle";
        "space e" = "workspace::ToggleLeftDock";
        "space a" = "agent::ToggleFocus";
        "space g" = "git_panel::ToggleFocus";
        "space d" = "diagnostics::Deploy";
        "space r" = "editor::Rename";
        "space c a" = "editor::ToggleCodeActions";
        "g d" = "editor::GoToDefinition";
        "g r" = "editor::FindAllReferences";
        "g i" = "editor::GoToImplementation";
        "g t" = "editor::GoToTypeDefinition";
        "K" = "editor::Hover";
        "] d" = "editor::GoToDiagnostic";
        "[ d" = "editor::GoToPrevDiagnostic";
        "space /" = "workspace::NewSearch";
      };
    }
    {
      context = "Terminal";
      bindings = {
        "ctrl-shift-t" = "workspace::ToggleBottomDock";
      };
    }
  ];
}
