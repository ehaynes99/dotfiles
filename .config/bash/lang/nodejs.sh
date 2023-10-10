# shellcheck disable=2139
[ "$NVM_DIR" = "" ] && export NVM_DIR="$HOME/.nvm"
safe_source /usr/share/nvm/init-nvm.sh
safe_source /usr/share/nvm/bash_completion

LOCK_MAJOR='lightship,@types/node,inversify,nanoid'
# alias pnpm="npx -y pnpm"
alias ncu="npx -y npm-check-updates -x '${LOCK_MAJOR}'"
# alias ncu="npx -y npm-check-updates"
alias ncuop="npx npm-check-updates --deep -i -t minor -x '/@openphone/' && npx npm-check-updates --deep -i -f '/@openphone/'"
alias ncum="npx -y npm-check-updates -f '${LOCK_MAJOR}' -t minor"
alias ncup='ncu -u && ncum -u && npm i'
alias esr='npx -y esbuild-runner'
alias ts-node='npx -y ts-node'
alias nest='npx -y -p @nestjs/cli nest'
alias turbo='npx -y -p turborepo turbo'
# alias npm='echo "USE pnpm!!!! To override this alias, use \npm"'

cd() {
	builtin cd "$@" && [[ -f .nvmrc ]] && nvm use
	return 0
}

cd .
