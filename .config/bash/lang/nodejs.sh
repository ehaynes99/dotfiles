# shellcheck disable=2139

pre_path "$HOME/.nodenv/bin"
eval "$(nodenv init - bash)"

LOCK_MAJOR='lightship,@types/node,inversify,nanoid'
alias tsc="npx -y -p typescript tsc"
# alias ncu="npx -y npm-check-updates -x '${LOCK_MAJOR}'"
# alias clean-js-artifacts=''
alias ncuop="npx npm-check-updates --deep -i -t minor -x '/@openphone/' && npx npm-check-updates --deep -i -f '/@openphone/'"
alias ncum="npx -y npm-check-updates -f '${LOCK_MAJOR}' -t minor"
alias ncup='ncu -u && ncum -u && npm i'
alias esr='npx -y esbuild-runner'
alias ncu="npx -y npm-check-updates"
alias ts-node='npx -y ts-node'
alias turbo='npx -y turbo'
alias asyncapi='npx -y -p @asyncapi/cli asyncapi'
alias tsx='npx -y tsx'
alias p='pnpm'
alias tsc-analyze='npx -y -p @typescript/analyze-trace analyze-trace'

alias auth0='npx -y -p auth0-deploy-cli a0deploy'

alias pnpm8='npx -y -p pnpm@8.5.1 pnpm'
alias coverage='brave coverage/lcov-report/index.html &'
# alias npm='echo "USE pnpm!!!! To override this alias, use \npm"'

alias npm-search='npm --searchlimit=100 search'

alias openapi-generator-cli='npx -y -p @openapitools/openapi-generator-cli openapi-generator-cli'
