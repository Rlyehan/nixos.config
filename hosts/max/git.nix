{ config, pkgs, ... }:

{
programs.git = {
  enable = true;
  userName = "Maximilian Huber";
  userEmail = "maximilian.hub@proton.me";

  includes = [
    {
      condition = "gitdir:~/work/";
      contents = {
        user = {
          email = "replace.me";  # Replace with your work email
        };
      };
    }
  ];

  extraConfig = {
    github.user = "Rlyehan";

    core = {
      excludesfile = "~/.config/git/ignore";
      filemode = false;
      trustctime = false;
      autocrlf = "input";
      untrackedCache = true;
      pager = "diff-so-fancy | less --tabs=4 -RFX";
      ignorecase = false;
    };

    credential = {
      helper = "libsecret";
    };

    pull.rebase = true;
    init.defaultBranch = "main";

    push = {
      default = "simple";
      followTags = true;
      autoSetupRemote = true;
    };

    fetch.prune = true;
    grep.lineNumber = true;
    help.autocorrect = 1;

    diff = {
      tool = "vimdiff";
      algorithm = "histogram";
    };

    merge = {
      conflictstyle = "diff3";
      defaultToUpstream = true;
    };

    rebase.autoStash = true;

    color = {
      ui = true;
      diff-highlight = {
        oldNormal = "red bold";
        oldHighlight = "red bold 52";
        newNormal = "green bold";
        newHighlight = "green bold 22";
      };
      diff = {
        meta = "yellow";
        frag = "magenta bold";
        commit = "yellow bold";
        old = "red bold";
        new = "green bold";
        whitespace = "red reverse";
      };
    };

    interactive = {
      diffFilter = "diff-so-fancy --patch";
    };

    filter.lfs = {
      clean = "git-lfs clean -- %f";
      smudge = "git-lfs smudge -- %f";
      process = "git-lfs filter-process";
      required = true;
    };
  };


    aliases = {
      aliases = "!git config --get-regexp alias | sed -re 's/alias\\.(\\S*)\\s(.*)$/\\1 = \\2/g'";
      st = "status -sb";
      c = "commit -m";
      ca = "commit --amend";
      co = "checkout";
      cob = "checkout -b";
      unstage = "reset HEAD --";
      uncommit = "reset --soft HEAD~1";
      amend = "commit --amend --no-edit";
      prune = "fetch --prune";
      stash-all = "stash save --include-untracked";
      push-lease = "push --force-with-lease";
      lg = "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
      ld = "log --pretty=format:'%C(yellow)%h %ad%Cred%d %Creset%s%Cblue [%cn]' --decorate --date=relative";
      dff = "diff --word-diff";
      review-local = "!git lg @{push}..";
    };
  };
}
