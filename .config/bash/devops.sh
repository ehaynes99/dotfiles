# AWS
alias ek=eksctl

# shellcheck disable=1090
source <(kubectl completion bash)
alias kub=kubectl
complete -F __start_kubectl kub
