# Git + GitHub CLI configuration
_:

{
  programs.gh = {
    enable = true;
    settings = {
      git_protocol = "ssh";
      browser = "xdg-open";
    };
  };

  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "Dana Pieluszczak";
        email = "danajp@users.noreply.github.com";
      };
      github.user = "danajp";
      url = {
        "ssh://git@github.com/" = {
          insteadOf = "https://github.com/";
        };
      };
      color = {
        log = "auto";
        diff = "auto";
        status = "auto";
      };
      push.default = "upstream";
      commit.gpgsign = true;
      init.defaultBranch = "main";

      alias = {
        lg ="log --graph --abbrev-commit --decorate --date=relative --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(bold yellow)%d%C(reset)'";
        lgnc ="log --graph --abbrev-commit --decorate --date=relative --format=format:'%h - (%ar) %s - %an%d'";
        lga = "!git lg --all";
        up = "!git remote update --prune; git merge --ff-only @{upstream}";
        mup = "merge --ff-only @{upstream}";
      };
    };
    ignores = [
      ".aider.chat.history.md"
      ".aider.tags.cache.*/"
    ];
    includes = [
      { path = "~/.gitconfig-signing"; }
    ];
  };
}
