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
            email = "replace.me";
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
        pager = "delta";
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
        colorMoved = "default";
        algorithm = "histogram";
      };

      merge = {
        conflictstyle = "diff3";
        defaultToUpstream = true;
      };

      rebase.autoStash = true;

      color = {
        ui = "auto";
        branch = {
          current = "yellow reverse";
          local = "yellow";
          remote = "green";
        };
        diff = {
          meta = "yellow bold";
          frag = "magenta bold";
          old = "red bold";
          new = "green bold";
        };
        status = {
          added = "yellow";
          changed = "green";
          untracked = "cyan";
        };
      };

      delta = {
        navigate = true;
        light = false;
        side-by-side = true;
        line-numbers = true;
      };

      interactive = {
        diffFilter = "delta --color-only";
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
      lga = "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --all";
      l = "log --oneline --decorate --graph";
      la = "log --oneline --decorate --graph --all";
      ls = "log --pretty=format:'%C(yellow)%h%Cred%d %Creset%s%Cblue [%cn]' --decorate";
      ll = "log --pretty=format:'%C(yellow)%h%Cred%d %Creset%s%Cblue [%cn]' --decorate --numstat";
      lnc = "log --pretty=format:'%h %s [%cn]'";
      ld = "log --pretty=format:'%C(yellow)%h %ad%Cred%d %Creset%s%Cblue [%cn]' --decorate --date=relative";
      le = "log --oneline --decorate";
      filelog = "log -u";
      fl = "log -u";
      dl = "!git ll -1";
      dlc = "diff --cached HEAD^";
      dr  = "diff --staged";
      diff-staged = "diff --staged";
      dff = "diff --word-diff";
      grep-group = "grep --break --heading --line-number";
      find = "!git ls-files | grep -i";
      f = "!git ls-files | grep -i";
      gr = "grep -Ii";
      gra = "!f() { A=$(pwd) && TOPLEVEL=$(git rev-parse --show-toplevel) && cd $TOPLEVEL && git grep --full-name -In $1 | xargs -I{} echo $TOPLEVEL/{} && cd $A; }; f";
      la = "!git config -l | grep alias | cut -c 7-";
      review-local = "!git lg @{push}..";
      recent-branches = "!git for-each-ref --sort=-committerdate refs/heads/ --format='%(authordate:short) %(color:red)%(objectname:short) %(color:yellow)%(refname:short)%(color:reset) (%(color:green)%(committerdate:relative)%(color:reset))' --count=10";
    };
  };
}
