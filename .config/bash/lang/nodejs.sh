# shellcheck disable=2139

pre_path "$HOME/.nodenv/bin"
eval "$(nodenv init - bash)"

LOCK_MAJOR='lightship,@types/node,inversify,nanoid'
# alias pnpm="npx -y pnpm"
alias ncu="npx -y npm-check-updates -x '${LOCK_MAJOR}'"
# alias ncu="npx -y npm-check-updates"
# alias ncu="npx -y npm-check-updates"
alias ncuop="npx npm-check-updates --deep -i -t minor -x '/@openphone/' && npx npm-check-updates --deep -i -f '/@openphone/'"
alias ncum="npx -y npm-check-updates -f '${LOCK_MAJOR}' -t minor"
alias ncup='ncu -u && ncum -u && npm i'
alias esr='npx -y esbuild-runner'
alias ts-node='npx -y ts-node'
alias turbo='npx -y -p turborepo turbo'
alias coverage='brave coverage/lcov-report/index.html &'
alias clean-js-artifacts=''
alias asyncapi='npx -y -p @asyncapi/cli asyncapi'
alias tsx='npx -y tsx'
# alias npm='echo "USE pnpm!!!! To override this alias, use \npm"'

alias npm-search='npm --searchlimit=100 search'
