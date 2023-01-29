[ -z "$NVM_DIR" ] && export NVM_DIR="$HOME/.nvm"
safe_source /usr/share/nvm/init-nvm.sh
safe_source /usr/share/nvm/bash_completion

alias ncu='npx -y npm-check-updates -x @types/node'
alias ncun='npx -y npm-check-updates -f @types/node -t minor'
alias ncup='ncu -u && ncun -u && npm i'
alias esr='npx -y esbuild-runner'
alias ts-node='npx -y ts-node'
alias nest='npx -y -p @nestjs/cli nest'

cd() {
  builtin cd "$@"
  [[ -f .nvmrc ]] && nvm use
}

cd .
