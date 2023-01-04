alias be='bundle exec'
alias brails='bundle exec rails'
alias brake='bundle exec rake'
alias birb='bundle exec irb'

if [ -d "$HOME/.rbenv/bin" ]; then
  pre_path "$HOME/.rbenv/bin"
  eval "$(rbenv init -)"
fi
