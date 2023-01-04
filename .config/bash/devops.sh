# AWS
alias ek=eksctl

# Kubernetes
source <(kubectl completion bash)
alias kub=kubectl
complete -F __start_kubectl kub
