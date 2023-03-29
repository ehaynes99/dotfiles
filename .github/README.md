# Eric's dotfiles

## To restore:
```shell
cd $HOME
git clone --bare git@github.com:ehaynes99/dotfiles.git $HOME/.dotfiles.git
dit checkout
ln -s $HOME/.dotfiles.gitconfig $HOME/.dotfiles.git/config
exec bash -l
```

The symlink for the git config allows using an ignore file without all of the problems usually associated with having a `.gitignore` file in the `$HOME` directory.


