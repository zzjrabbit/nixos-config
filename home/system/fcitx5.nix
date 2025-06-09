{ pkgs, ... }:

{
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5 = {
      waylandFrontend = true;
      addons = with pkgs; [
        fcitx5-gtk
        fcitx5-chinese-addons
      ];
      settings = {
        inputMethod = {
          GroupOrder."0" = "Default";
          "Groups/0" = {
            Name = "Default";
            "Default Layout" = "us";
            DefaultIM = "shuangpin";
          };
          "Groups/0/Items/0".Name = "keyboard-us";
          "Groups/0/Items/1".Name = "shuangpin";
        };
        addons = {
          pinyin = {
            globalSection = {
              ShuangpinProfile = "Ziranma";
              CloudPinyinEnabled = "False";
              FirstRun = "False";
            };
          };
          classicui.globalSection = {
            Theme = "adwaita-dark";
            Font = "Source Han Sans SC 12";
          };
        };
      };
      themes.adwaita-dark = {
        theme = ''
          [Metadata]
          Name="Adwaita Dark"
          Version=1
          Author=moeday & wendster
          Description="Adwaita Theme"

          [InputPanel]
          NormalColor=#fafafa
          HighlightColor=#fafafa
          HighlightBackgroundColor=#393939
          HighlightCandidateColor=#fafafa
          EnableBlur=False
          BlurMask=
          FullWidthHighlight=True
          PageButtonAlignment=Top

          [InputPanel/BlurMargin]
          Left=0
          Right=0
          Top=0
          Bottom=0

          [InputPanel/Background]
          Image=
          Color=#242424
          BorderColor=#4e4e4e
          BorderWidth=2
          Overlay=
          Gravity="Top Left"
          OverlayOffsetX=0
          OverlayOffsetY=0
          HideOverlayIfOversize=False

          [InputPanel/Background/Margin]
          Left=2
          Right=2
          Top=2
          Bottom=2

          [InputPanel/Background/OverlayClipMargin]
          Left=0
          Right=0
          Top=0
          Bottom=0

          [InputPanel/Highlight]
          Image=
          Color=#195aaa
          BorderColor=#ffffff00
          BorderWidth=0
          Overlay=
          Gravity="Top Left"
          OverlayOffsetX=0
          OverlayOffsetY=0
          HideOverlayIfOversize=False

          [InputPanel/Highlight/Margin]
          Left=10
          Right=10
          Top=5
          Bottom=5

          [InputPanel/Highlight/OverlayClipMargin]
          Left=0
          Right=0
          Top=0
          Bottom=0

          [InputPanel/Highlight/HighlightClickMargin]
          Left=0
          Right=0
          Top=0
          Bottom=0

          [InputPanel/ContentMargin]
          Left=0
          Right=0
          Top=0
          Bottom=0

          [InputPanel/TextMargin]
          Left=14
          Right=14
          Top=9
          Bottom=9

          [InputPanel/PrevPage]
          Image=

          [InputPanel/PrevPage/ClickMargin]
          Left=10
          Right=10
          Top=9
          Bottom=9

          [InputPanel/NextPage]
          Image=

          [InputPanel/NextPage/ClickMargin]
          Left=5
          Right=5
          Top=4
          Bottom=4

          [InputPanel/ShadowMargin]
          Left=0
          Right=0
          Top=0
          Bottom=0

          [Menu]
          NormalColor=#000000
          HighlightCandidateColor=#ffffff
          Spacing=0

          [Menu/Background]
          Image=
          Color=#ffffff
          BorderColor=#c0c0c0
          BorderWidth=2
          Overlay=
          Gravity="Top Left"
          OverlayOffsetX=0
          OverlayOffsetY=0
          HideOverlayIfOversize=False

          [Menu/Background/Margin]
          Left=2
          Right=2
          Top=2
          Bottom=2

          [Menu/Background/OverlayClipMargin]
          Left=0
          Right=0
          Top=0
          Bottom=0

          [Menu/Highlight]
          Image=
          Color=#808080
          BorderColor=#ffffff00
          BorderWidth=0
          Overlay=
          Gravity="Top Left"
          OverlayOffsetX=0
          OverlayOffsetY=0
          HideOverlayIfOversize=False

          [Menu/Highlight/Margin]
          Left=5
          Right=5
          Top=5
          Bottom=5

          [Menu/Highlight/OverlayClipMargin]
          Left=0
          Right=0
          Top=0
          Bottom=0

          [Menu/Separator]
          Image=
          Color=#c0c0c0
          BorderColor=#ffffff00
          BorderWidth=0
          Overlay=
          Gravity="Top Left"
          OverlayOffsetX=0
          OverlayOffsetY=0
          HideOverlayIfOversize=False

          [Menu/Separator/Margin]
          Left=0
          Right=0
          Top=0
          Bottom=0

          [Menu/Separator/OverlayClipMargin]
          Left=0
          Right=0
          Top=0
          Bottom=0

          [Menu/CheckBox]
          Image=radio.png
          Color=#ffffff
          BorderColor=#ffffff00
          BorderWidth=0
          Overlay=
          Gravity="Top Left"
          OverlayOffsetX=0
          OverlayOffsetY=0
          HideOverlayIfOversize=False

          [Menu/CheckBox/Margin]
          Left=0
          Right=0
          Top=0
          Bottom=0

          [Menu/CheckBox/OverlayClipMargin]
          Left=0
          Right=0
          Top=0
          Bottom=0

          [Menu/SubMenu]
          Image=arrow.png
          Color=#ffffff
          BorderColor=#ffffff00
          BorderWidth=0
          Overlay=
          Gravity="Top Left"
          OverlayOffsetX=0
          OverlayOffsetY=0
          HideOverlayIfOversize=False

          [Menu/SubMenu/Margin]
          Left=0
          Right=0
          Top=0
          Bottom=0

          [Menu/SubMenu/OverlayClipMargin]
          Left=0
          Right=0
          Top=0
          Bottom=0

          [Menu/ContentMargin]
          Left=2
          Right=2
          Top=2
          Bottom=2

          [Menu/TextMargin]
          Left=5
          Right=5
          Top=5
          Bottom=5

          [AccentColorField]
          0="Input Panel Border"
          1="Input Panel Highlight Candidate Background"
          2="Input Panel Highlight"
          3="Menu Border"
          4="Menu Separator"
          5="Menu Selected Item Background"
        '';
      };
    };
  };
}