# shellcheck disable=2139

eval "$(mise activate bash --shims)"

export PNPM_HOME="$HOME/.local/share/pnpm"
pre_path "$HOME/.local/share/pnpm"

alias p='pnpm'
alias pi='pnpm i'
alias pb='pnpm build'
alias pib='pnpm i && pnpm build'
alias pt='pnpm typecheck'
alias pit='pnpm i && pnpm typecheck'
alias pgg='pnpm gql:gen'

LOCK_MAJOR='@types/node'
# alias ncu="npx -y npm-check-updates -x '${LOCK_MAJOR}'"
alias ncu="npx -y npm-check-updates"
alias tsc="npx -y -p typescript tsc"
alias tsx='npx -y tsx'
alias turbo='npx -y -p turborepo turbo'
alias tsc-analyze='npx -y -p @typescript/analyze-trace analyze-trace'
alias wgc="npx -y wgc"
# alias auth0='npx -y -p auth0-deploy-cli a0deploy'

alias pnpm8='npx -y -p pnpm@8.5.1 pnpm'
alias coverage='brave coverage/lcov-report/index.html &'
# this defaults to 20 and doesn't mention this flag if there are more...
alias npm-search='npm --searchlimit=100 search'
alias openapi-generator-cli='npx -y -p @openapitools/openapi-generator-cli openapi-generator-cli'
alias piai='npx -y -p @earendil-works/pi-coding-agent pi'
