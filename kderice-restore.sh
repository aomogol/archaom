#!/bin/bash

export PATH=$PATH:~/.local/bin
cp -r $HOME/archaom/dotfiles/* $HOME/.config/
pip install konsave
konsave -i $HOME/archaom/kde.knsv
sleep 1
konsave -a kde
