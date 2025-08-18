{ ... }:
{
  programs.alacritty = {
    enable = true;
    settings = {
      env.TERM = "xterm-256color";
      font = {
        normal = {
			family = "Fira Code";
		};
		bold = {
			family = "Fira Code";
		};
		italic = {
			family = "Fira Code";
		};
		bold_italic = {
			family = "Fira Code";
		};
		size = 14;
      };
      scrolling.multiplier = 5;
      selection.save_to_clipboard = true;
	  window.opacity = 0.8;
	};
  };
}
