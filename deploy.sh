#!/bin/bash

#get the directly of where this script is run, and consequently where the files are located
SCRIPTPATH=$( cd $(dirname $0) ; pwd -P )

SYSTEM=${OSTYPE//[0-9.]/}

#warn if they already have one of the .bak files that exists
if [[  -e ~/.tmux.conf.bak || -e ~/.tmux.reset.conf.bak \
    || -e ~/.tmux.colors.conf.bak || -e ~/.tmux.system.conf.bak \
    || -e ~/.zshrc.bak || -e ~/.vimrc.bak \
    || -e ~/.dircolors.bak || -e ~/.vim.bak
    || -e ~/.zsh.bak || -e ~/.gitconfig.bak ]]; then
    echo "Warning! one or more *.bak files exist in your home directory that may get overwritten!"
    read -p "Continue? [y/n]" yn
    while true; do
        case $yn in
            [Yy]* )
                break
                ;;
            [Nn]* )
                exit
                ;;
            * )
                read -p "Please answer yes or no. [y/n]" yn
                ;;
        esac
    done
fi

#git depends on being in directory, so cd to directory first
cd $SCRIPTPATH
#init and update if we haven't already
echo Updating submodules...
git submodule init
git submodule update

function backupIfNotSymlink() {
    if [[ -L $1 ]]; then
        rm -v $1
    elif [[ -e $1 ]]; then
        mv -v -f $1 $1.bak
    fi
}

#TODO, just create a mappings array to install

#remove symlinks if they exist or backup file
backupIfNotSymlink ~/.tmux.conf
backupIfNotSymlink ~/.tmux.reset.conf
backupIfNotSymlink ~/.tmux.colors.conf
backupIfNotSymlink ~/.tmux.system.conf
backupIfNotSymlink ~/.zshrc
backupIfNotSymlink ~/.zshrc.system
backupIfNotSymlink ~/.vimrc
backupIfNotSymlink ~/.dircolors
backupIfNotSymlink ~/.gitconfig
rm -rf ~/.vim.bak
backupIfNotSymlink ~/.vim
backupIfNotSymlink ~/.zsh

#make the new symlinks
ln -v -s $SCRIPTPATH/tmux.conf ~/.tmux.conf
ln -v -s $SCRIPTPATH/tmux.reset.conf ~/.tmux.reset.conf
ln -v -s $SCRIPTPATH/tmux-colors-solarized/tmuxcolors-256.conf ~/.tmux.colors.conf
ln -v -s $SCRIPTPATH/vimrc ~/.vimrc
ln -v -s $SCRIPTPATH/zshrc ~/.zshrc
ln -v -s $SCRIPTPATH/dircolors-solarized/dircolors.ansi-dark ~/.dircolors
ln -v -s $SCRIPTPATH/zsh ~/.zsh
ln -v -s $SCRIPTPATH/template.html ~/.template.html
#ln -v -s $SCRIPTPATH/gitconfig ~/.gitconfig
#COPY GITCONFIG BECAUSE IF ITS BROKEN ITS ANNOYING TO MERGE
cp -v $SCRIPTPATH/gitconfig ~/.gitconfig

#these two files depend upon system type
ln -s $SCRIPTPATH/$SYSTEM/tmux.system.conf ~/.tmux.system.conf
ln -s $SCRIPTPATH/$SYSTEM/zshrc.system ~/.zshrc.system

#create the local changes files if they don't exist
touch ~/.tmux.local.conf
touch ~/.zshrc.local
touch ~/.vimrc.local

#install bundles
echo Creating .vim/autoload and .vim/bundle
mkdir -p ~/.vim
rm -f ~/.vim/autoload
rm -f ~/.vim/bundle
ln -v -s $SCRIPTPATH/vim/vim-pathogen/autoload ~/.vim/autoload
ln -v -s $SCRIPTPATH/vim/bundle ~/.vim/bundle
