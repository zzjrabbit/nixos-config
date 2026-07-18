{ config, inputs, pkgs, ... }:

let
  rimeMoqi = pkgs.stdenvNoCC.mkDerivation {
    pname = "rime-shuangpin-fuzhuma";
    version = "2025-08-02";
    src = inputs.rime-shuangpin-fuzhuma;

    dontConfigure = true;
    dontBuild = true;

    installPhase = ''
      mkdir -p $out/share/rime-data
      cp -r . $out/share/rime-data
      mv $out/share/rime-data/default.yaml \
        $out/share/rime-data/rime_moqi_suggestion.yaml
    '';
  };

  highlightSvg = pkgs.writeText "fcitx5-highlight.svg" ''
    <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24">
      <rect x="0.5" y="0.5" width="23" height="23" rx="7.5"
            fill="#${config.lib.stylix.colors.base02}"
            stroke="#${config.lib.stylix.colors.base0D}"/>
    </svg>
  '';

  highlightPng = pkgs.runCommand "fcitx5-highlight.png" {
    nativeBuildInputs = [ pkgs.librsvg ];
  } ''
    rsvg-convert ${highlightSvg} --output $out
  '';
in
{
  home.file.".local/share/fcitx5/rime/default.custom.yaml".text = ''
    patch:
      __include: rime_moqi_suggestion:/
      schema_list:
        - schema: moqi_wan_zrm
  '';

  home.file.".local/share/fcitx5/themes/orbital-glass/theme.conf".text = ''
    [Metadata]
    Name=Orbital Glass
    Version=1
    Author=Local
    Description=Blurred translucent theme matching the desktop palette
    ScaleWithDPI=True

    [InputPanel]
    EnableBlur=True
    BlurMask=panel.svg
    FullWidthHighlight=True
    NormalColor=#${config.lib.stylix.colors.base05}
    HighlightCandidateColor=#${config.lib.stylix.colors.base05}
    HighlightColor=#${config.lib.stylix.colors.base0D}
    HighlightBackgroundColor=#${config.lib.stylix.colors.base02}
    PageButtonAlignment=Last Candidate

    [InputPanel/TextMargin]
    Left=9
    Right=9
    Top=7
    Bottom=7

    [InputPanel/ContentMargin]
    Left=8
    Right=8
    Top=7
    Bottom=7

    [InputPanel/Background]
    Color=#${config.lib.stylix.colors.base01}
    BorderColor=#${config.lib.stylix.colors.base03}
    BorderWidth=0
    Image=panel.svg

    [InputPanel/Background/Margin]
    Left=14
    Right=14
    Top=14
    Bottom=14

    [InputPanel/Highlight]
    Color=#${config.lib.stylix.colors.base02}
    BorderWidth=0
    Image=highlight.png

    [InputPanel/Highlight/Margin]
    Left=8
    Right=8
    Top=8
    Bottom=8

    [Menu]
    NormalColor=#${config.lib.stylix.colors.base05}
    HighlightCandidateColor=#${config.lib.stylix.colors.base05}
    Spacing=2

    [Menu/Background]
    Color=#${config.lib.stylix.colors.base01}
    BorderColor=#${config.lib.stylix.colors.base03}
    BorderWidth=0
    Image=panel.svg

    [Menu/Background/Margin]
    Left=14
    Right=14
    Top=14
    Bottom=14

    [Menu/ContentMargin]
    Left=8
    Right=8
    Top=8
    Bottom=8

    [Menu/TextMargin]
    Left=8
    Right=8
    Top=6
    Bottom=6

    [Menu/Highlight]
    Color=#${config.lib.stylix.colors.base02}
    BorderWidth=0
    Image=highlight.png

    [Menu/Highlight/Margin]
    Left=8
    Right=8
    Top=8
    Bottom=8

    [Menu/Separator]
    Color=#${config.lib.stylix.colors.base03}
  '';

  home.file.".local/share/fcitx5/themes/orbital-glass/panel.svg".text = ''
    <svg xmlns="http://www.w3.org/2000/svg" width="40" height="40" viewBox="0 0 40 40">
      <defs>
        <linearGradient id="glass" x1="0" y1="0" x2="1" y2="1">
          <stop offset="0" stop-color="#${config.lib.stylix.colors.base02}" stop-opacity="0.90"/>
          <stop offset="0.45" stop-color="#${config.lib.stylix.colors.base01}" stop-opacity="0.86"/>
          <stop offset="1" stop-color="#${config.lib.stylix.colors.base00}" stop-opacity="0.82"/>
        </linearGradient>
      </defs>
      <rect x="1.5" y="1.5" width="37" height="37" rx="12"
            fill="url(#glass)"
            stroke="#${config.lib.stylix.colors.base06}" stroke-opacity="0.28"/>
      <path d="M13 2h14a11 11 0 0 1 10.5 8" fill="none"
            stroke="#${config.lib.stylix.colors.base07}" stroke-opacity="0.18"
            stroke-linecap="round"/>
    </svg>
  '';

  home.file.".local/share/fcitx5/themes/orbital-glass/highlight.png".source = highlightPng;

  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5 = {
      waylandFrontend = true;
      addons = [
        pkgs.fcitx5-gtk
        (pkgs.fcitx5-rime.override {
          rimeDataPkgs = [
            pkgs.rime-data
            rimeMoqi
          ];
        })
      ];
      settings = {
        inputMethod = {
          GroupOrder."0" = "Default";
          "Groups/0" = {
            Name = "Default";
            "Default Layout" = "us";
            DefaultIM = "rime";
          };
          "Groups/0/Items/0".Name = "keyboard-us";
          "Groups/0/Items/1".Name = "rime";
        };
        addons.classicui.globalSection = {
          Theme = "orbital-glass";
          Font = "Source Han Sans SC 12";
          UseAccentColor = "False";
          UseDarkTheme = "False";
          "Vertical Candidate List" = "True";
        };
      };
    };
  };
}
