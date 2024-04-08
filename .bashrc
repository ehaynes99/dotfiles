source ~/.config/bash/setup.sh

# pnpm
export PNPM_HOME="/home/erich/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end
