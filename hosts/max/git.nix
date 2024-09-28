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
      "https://github.com".helper = "!/usr/bin/gh auth git-credential";
      "https://gist.github.com".helper = "!/usr/bin/gh auth git-credential";
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
      lga = "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --all";
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
