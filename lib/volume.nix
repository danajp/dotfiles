# Volume control script with audio feedback
{ pkgs }:

pkgs.writeShellScriptBin "volume" ''
  SINK='@DEFAULT_SINK@'
  STEP='5%'
  FEEDBACK_SOUND="${../assets/click.wav}"

  case "$1" in
    up)
      ${pkgs.pulseaudio}/bin/pactl set-sink-volume "''${SINK}" "+''${STEP}"
      ;;
    down)
      ${pkgs.pulseaudio}/bin/pactl set-sink-volume "''${SINK}" "-''${STEP}"
      ;;
    toggle-mute)
      ${pkgs.pulseaudio}/bin/pactl set-sink-mute "''${SINK}" toggle
      ;;
    *)
      echo "Command $1 isn't something I recognize"
      exit 1
      ;;
  esac

  ${pkgs.pulseaudio}/bin/paplay "''${FEEDBACK_SOUND}"
''
