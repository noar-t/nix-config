{
  ...
}:
{
  # improved ls
  programs.eza = {
    enable = true;
    enableFishIntegration = true;

    # list git status if tracked
    git = true;

    # show icons next to items
    icons = true;
  };
}
